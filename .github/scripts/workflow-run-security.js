"use strict";

const fs = require("node:fs");
const path = require("node:path");
const { execFileSync } = require("node:child_process");

const DEFAULT_PROTECTED_PATHS = [
  ".github/actions/",
  ".github/scripts/",
  ".github/workflows/",
  "ci/",
  "scripts/",
  "upstream.Dockerfile",
];

const MAX_ARTIFACT_BYTES = 1024 * 1024;
const MAX_COMMENT_BYTES = 60 * 1024;
const MAX_COMMENT_FILES = 20;

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function normalizeRepository(value) {
  return String(value || "").toLowerCase();
}

function isProtectedPath(filename, protectedPaths = DEFAULT_PROTECTED_PATHS) {
  const normalized = String(filename || "").replaceAll("\\", "/");

  return protectedPaths.some((rule) =>
    rule.endsWith("/") ? normalized.startsWith(rule) : normalized === rule,
  );
}

async function candidatePullRequests({ github, context, run }) {
  const fromEvent = Array.isArray(run.pull_requests) ? run.pull_requests : [];
  if (fromEvent.length > 0) {
    return fromEvent;
  }

  const response = await github.rest.repos.listPullRequestsAssociatedWithCommit({
    owner: context.repo.owner,
    repo: context.repo.repo,
    commit_sha: run.head_sha,
  });

  return response.data;
}

async function resolveTrustedPullRequest({
  github,
  context,
  expectedWorkflowName,
  expectedBaseBranch = "main",
  approvedCiLabel = "allow/ci-changes",
  protectedPaths = DEFAULT_PROTECTED_PATHS,
}) {
  const run = context.payload.workflow_run;
  assert(run, "workflow_run payload is missing");
  assert(run.name === expectedWorkflowName, `unexpected workflow: ${run.name}`);
  assert(run.event === "pull_request", `unexpected workflow event: ${run.event}`);
  assert(run.head_sha, "workflow head SHA is missing");

  const candidates = await candidatePullRequests({ github, context, run });
  assert(candidates.length === 1, `expected one pull request, found ${candidates.length}`);

  const number = Number(candidates[0].number);
  assert(Number.isSafeInteger(number) && number > 0, "invalid pull request number");

  const repository = `${context.repo.owner}/${context.repo.repo}`;
  const response = await github.rest.pulls.get({
    owner: context.repo.owner,
    repo: context.repo.repo,
    pull_number: number,
  });
  const pull = response.data;

  assert(pull.state === "open", `pull request #${number} is not open`);
  assert(
    normalizeRepository(pull.base.repo.full_name) === normalizeRepository(repository),
    `pull request #${number} targets an unexpected repository`,
  );
  assert(
    pull.base.ref === expectedBaseBranch,
    `pull request #${number} targets ${pull.base.ref}, not ${expectedBaseBranch}`,
  );
  const runMatchesHead = pull.head.sha === run.head_sha;
  const runMatchesMerge =
    Boolean(pull.merge_commit_sha) && pull.merge_commit_sha === run.head_sha;
  assert(
    runMatchesHead || runMatchesMerge,
    `workflow SHA ${run.head_sha} is stale for pull request #${number}`,
  );

  const candidateHeadRepository =
    candidates[0].head && candidates[0].head.repo
      ? candidates[0].head.repo.full_name
      : undefined;
  if (candidateHeadRepository) {
    assert(
      normalizeRepository(pull.head.repo.full_name) ===
        normalizeRepository(candidateHeadRepository),
      `workflow repository does not match pull request #${number}`,
    );
  } else if (runMatchesHead && run.head_repository && run.head_repository.full_name) {
    assert(
      normalizeRepository(pull.head.repo.full_name) ===
        normalizeRepository(run.head_repository.full_name),
      `workflow repository does not match pull request #${number}`,
    );
  }

  const files = await github.paginate(github.rest.pulls.listFiles, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    pull_number: number,
    per_page: 100,
  });
  const protectedFiles = files
    .map((file) => file.filename)
    .filter((filename) => isProtectedPath(filename, protectedPaths));
  const labels = (pull.labels || []).map((label) =>
    typeof label === "string" ? label : label.name,
  );

  assert(
    protectedFiles.length === 0 || labels.includes(approvedCiLabel),
    `pull request #${number} changes protected CI files without ${approvedCiLabel}: ${protectedFiles.join(", ")}`,
  );

  return {
    number,
    headSha: pull.head.sha,
    protectedFiles,
    approvedCiChanges: labels.includes(approvedCiLabel),
  };
}

function validateCommentEntries(entries, maxFiles = MAX_COMMENT_FILES) {
  const files = entries.filter(Boolean);
  assert(files.length <= maxFiles, `comment artifact contains more than ${maxFiles} files`);

  for (const entry of files) {
    assert(
      /^[A-Za-z0-9][A-Za-z0-9._-]{0,127}\.md$/.test(entry),
      `unsafe comment artifact entry: ${entry}`,
    );
  }

  return files;
}

function sanitizeCommentBody(body, maxBytes = MAX_COMMENT_BYTES) {
  const cleaned = String(body || "").replaceAll("\0", "").trim();
  assert(Buffer.byteLength(cleaned, "utf8") <= maxBytes, "comment body is too large");

  if (!cleaned) {
    return "";
  }

  const neutralized = cleaned
    .replace(/@(?=[A-Za-z0-9_-])/g, "@\u200b")
    .replace(/!\[/g, "\\![");
  const notice =
    "> Automated validator output from an untrusted pull-request test run. " +
    "Links and content below are not maintainer-authored.";

  return `${notice}\n\n${neutralized}`;
}

async function postWorkflowComments({
  github,
  context,
  prNumber,
  runId,
  workspace,
  artifactNames = ["pr_comments", "pr_comments_test"],
}) {
  const artifacts = await github.paginate(github.rest.actions.listWorkflowRunArtifacts, {
    owner: context.repo.owner,
    repo: context.repo.repo,
    run_id: runId,
    per_page: 100,
  });

  for (const artifactName of artifactNames) {
    const artifact = artifacts.find((item) => item.name === artifactName);
    if (!artifact) {
      continue;
    }

    assert(!artifact.expired, `artifact ${artifactName} has expired`);
    assert(
      artifact.size_in_bytes <= MAX_ARTIFACT_BYTES,
      `artifact ${artifactName} exceeds ${MAX_ARTIFACT_BYTES} bytes`,
    );

    const download = await github.rest.actions.downloadArtifact({
      owner: context.repo.owner,
      repo: context.repo.repo,
      artifact_id: artifact.id,
      archive_format: "zip",
    });
    const archive = path.join(workspace, `${artifactName}.zip`);
    fs.writeFileSync(archive, Buffer.from(download.data));

    const listing = execFileSync("unzip", ["-Z1", archive], {
      encoding: "utf8",
      maxBuffer: MAX_COMMENT_BYTES,
    });
    const entries = validateCommentEntries(listing.split(/\r?\n/).filter(Boolean));

    for (const entry of entries) {
      const rawBody = execFileSync("unzip", ["-p", archive, entry], {
        encoding: "utf8",
        maxBuffer: MAX_COMMENT_BYTES,
      });
      const body = sanitizeCommentBody(rawBody);
      if (!body) {
        continue;
      }

      await github.rest.issues.createComment({
        issue_number: prNumber,
        owner: context.repo.owner,
        repo: context.repo.repo,
        body,
      });
    }
  }
}

module.exports = {
  DEFAULT_PROTECTED_PATHS,
  isProtectedPath,
  postWorkflowComments,
  resolveTrustedPullRequest,
  sanitizeCommentBody,
  validateCommentEntries,
};
