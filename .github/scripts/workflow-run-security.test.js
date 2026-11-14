"use strict";

const assert = require("node:assert/strict");
const test = require("node:test");

const {
  isProtectedPath,
  resolveTrustedPullRequest,
  sanitizeCommentBody,
  validateCommentEntries,
} = require("./workflow-run-security");

function fixture({ run = {}, pull = {}, files = [] } = {}) {
  const repository = "k8s-operatorhub/community-operators";
  const workflowRun = {
    name: "Operator test",
    event: "pull_request",
    head_sha: "abc123",
    head_repository: { full_name: "contributor/community-operators" },
    pull_requests: [
      {
        number: 42,
        head: {
          sha: "abc123",
          repo: { full_name: "contributor/community-operators" },
        },
      },
    ],
    ...run,
  };
  const pullRequest = {
    number: 42,
    state: "open",
    merge_commit_sha: "merge123",
    base: {
      ref: "main",
      repo: { full_name: repository },
    },
    head: {
      sha: "abc123",
      repo: { full_name: "contributor/community-operators" },
    },
    labels: [],
    ...pull,
  };
  const github = {
    paginate: async () => files,
    rest: {
      pulls: {
        get: async () => ({ data: pullRequest }),
        listFiles: Symbol("listFiles"),
      },
      repos: {
        listPullRequestsAssociatedWithCommit: async () => ({
          data: [{ number: pullRequest.number }],
        }),
      },
    },
  };
  const context = {
    repo: { owner: "k8s-operatorhub", repo: "community-operators" },
    payload: { workflow_run: workflowRun },
  };

  return { context, github };
}

test("accepts a current operator-only pull request", async () => {
  const { context, github } = fixture({
    files: [{ filename: "operators/example/1.0.0/manifests/example.yaml" }],
  });

  const result = await resolveTrustedPullRequest({
    github,
    context,
    expectedWorkflowName: "Operator test",
  });

  assert.equal(result.number, 42);
  assert.deepEqual(result.protectedFiles, []);
});

test("accepts the current synthetic merge commit SHA", async () => {
  const { context, github } = fixture({
    run: { head_sha: "merge123" },
  });

  const result = await resolveTrustedPullRequest({
    github,
    context,
    expectedWorkflowName: "Operator test",
  });

  assert.equal(result.number, 42);
});

test("uses commit association when workflow_run omits pull requests", async () => {
  const { context, github } = fixture({
    run: { pull_requests: [] },
  });

  const result = await resolveTrustedPullRequest({
    github,
    context,
    expectedWorkflowName: "Operator test",
  });

  assert.equal(result.number, 42);
});

test("rejects a stale workflow run", async () => {
  const { context, github } = fixture({
    pull: {
      head: {
        sha: "newer456",
        repo: { full_name: "contributor/community-operators" },
      },
    },
  });

  await assert.rejects(
    resolveTrustedPullRequest({
      github,
      context,
      expectedWorkflowName: "Operator test",
    }),
    /is stale/,
  );
});

test("rejects closed pull requests", async () => {
  const { context, github } = fixture({
    pull: { state: "closed" },
  });

  await assert.rejects(
    resolveTrustedPullRequest({
      github,
      context,
      expectedWorkflowName: "Operator test",
    }),
    /is not open/,
  );
});

test("rejects pull requests targeting another branch", async () => {
  const { context, github } = fixture({
    pull: {
      base: {
        ref: "release",
        repo: { full_name: "k8s-operatorhub/community-operators" },
      },
    },
  });

  await assert.rejects(
    resolveTrustedPullRequest({
      github,
      context,
      expectedWorkflowName: "Operator test",
    }),
    /targets release, not main/,
  );
});

test("rejects workflow runs without an associated pull request", async () => {
  const { context, github } = fixture({
    run: { pull_requests: [] },
  });
  github.rest.repos.listPullRequestsAssociatedWithCommit = async () => ({ data: [] });

  await assert.rejects(
    resolveTrustedPullRequest({
      github,
      context,
      expectedWorkflowName: "Operator test",
    }),
    /expected one pull request, found 0/,
  );
});

test("rejects protected CI changes without maintainer approval", async () => {
  const { context, github } = fixture({
    files: [{ filename: ".github/workflows/operator_test.yaml" }],
  });

  await assert.rejects(
    resolveTrustedPullRequest({
      github,
      context,
      expectedWorkflowName: "Operator test",
    }),
    /without allow\/ci-changes/,
  );
});

test("accepts protected CI changes with maintainer approval", async () => {
  const { context, github } = fixture({
    pull: { labels: [{ name: "allow/ci-changes" }] },
    files: [{ filename: ".github/workflows/operator_test.yaml" }],
  });

  const result = await resolveTrustedPullRequest({
    github,
    context,
    expectedWorkflowName: "Operator test",
  });

  assert.equal(result.approvedCiChanges, true);
  assert.deepEqual(result.protectedFiles, [".github/workflows/operator_test.yaml"]);
});

test("rejects ambiguous pull request associations", async () => {
  const { context, github } = fixture({
    run: { pull_requests: [{ number: 42 }, { number: 43 }] },
  });

  await assert.rejects(
    resolveTrustedPullRequest({
      github,
      context,
      expectedWorkflowName: "Operator test",
    }),
    /expected one pull request/,
  );
});

test("recognizes protected paths", () => {
  assert.equal(isProtectedPath(".github/workflows/test.yaml"), true);
  assert.equal(isProtectedPath("ci/prow/test.sh"), true);
  assert.equal(isProtectedPath("operators/example/1.0.0/bundle.yaml"), false);
});

test("rejects unsafe comment archive entries", () => {
  assert.throws(
    () => validateCommentEntries(["../../merge.md"]),
    /unsafe comment artifact entry/,
  );
  assert.throws(
    () => validateCommentEntries(["nested/comment.md"]),
    /unsafe comment artifact entry/,
  );
});

test("limits comment artifact file counts", () => {
  const entries = Array.from({ length: 21 }, (_, index) => `comment-${index}.md`);
  assert.throws(() => validateCommentEntries(entries), /more than 20 files/);
});

test("marks artifact comments as untrusted and neutralizes mentions and images", () => {
  const body = sanitizeCommentBody("/merge possible\n@maintainer\n![tracking](https://example.test)");

  assert.match(body, /^> Automated validator output/);
  assert.doesNotMatch(body, /^\/merge/);
  assert.match(body, /@\u200bmaintainer/);
  assert.match(body, /\\!\[tracking\]/);
});

test("rejects oversized comment bodies", () => {
  assert.throws(() => sanitizeCommentBody("x".repeat(100), 32), /too large/);
});
