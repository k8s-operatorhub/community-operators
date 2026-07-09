# Contributing via File-Based Catalog (FBC)

File-Based Catalog support is the recommended approach for operators that need to:
- Change upgrade graph topology after a bundle has already been released
- Set or change the default channel without publishing a new bundle version
- Add skip or skipRange relationships retroactively

This mirrors the workflow already in use in
[community-operators-prod](https://github.com/redhat-openshift-ecosystem/community-operators-prod)
so that dual-submitting operators face minimal friction.

## Prerequisites

- `podman` or `docker`
- `make`
- An operator already in this repository

## Opting in

Add a `fbc:` section to your operator's `ci.yaml`:

```yaml
# operators/<operator>/ci.yaml
fbc:
  enabled: true
  catalog_mapping:
    - template_name: basic.yaml      # file inside catalog-templates/
      catalog_names: ["latest"]      # must be "latest" for this repo
      type: olm.template.basic       # or olm.semver
```

## Onboarding an existing operator

Download the shared Makefile and run the onboarding tool:

```bash
cd operators/<operator>
wget https://raw.githubusercontent.com/redhat-openshift-ecosystem/operator-pipelines/main/fbc/Makefile
make fbc-onboarding
```

This generates `catalog-templates/` files and updates `ci.yaml` automatically.

## Directory structure after onboarding

```
operators/<operator>/
├── <version>/
│   ├── manifests/
│   ├── metadata/
│   └── release-config.yaml        # optional: auto-add bundle to catalog on merge
├── catalog-templates/
│   └── basic.yaml                 # or semver.yaml; one template for "latest"
├── ci.yaml                        # fbc.enabled: true + catalog_mapping
└── Makefile
```

Top of repo:
```
catalogs/
└── latest/
    └── <operator>/
        └── catalog.yaml           # rendered output; committed alongside templates
```

## Template types

| Type | When to use |
|---|---|
| `olm.template.basic` | Full control over channel entries, replaces, skips |
| `olm.semver` | Semver-driven channels (Fast/Stable/Candidate) |

Full reference: https://olm.operatorframework.io/docs/reference/catalog-templates/

## Rendering catalogs locally

```bash
cd operators/<operator>
make catalogs     # renders catalog-templates/ → ../../catalogs/latest/<operator>/
make validate     # runs opm validate on rendered output
```

Commit **both** the template changes and the rendered `catalogs/latest/<operator>/catalog.yaml`.

## release-config.yaml (auto-release)

Placing a `release-config.yaml` alongside a new bundle version causes the release pipeline
to automatically open a second PR that updates your catalog template — no manual template
editing required:

```yaml
# operators/<operator>/<version>/release-config.yaml
merge: true
catalog_templates:
  - template_name: basic.yaml
    channels: [stable]
    replaces: <operator>.v1.1.0    # optional
```

Schema: https://github.com/redhat-openshift-ecosystem/operator-pipelines/blob/main/operatorcert/schemas/release-config-schema.json

## Differences from community-operators-prod

| | community-operators (this repo) | community-operators-prod |
|---|---|---|
| Catalog versions | Single `latest` | Per OCP version (v4.12–v4.22) |
| Version promotion | Not applicable | `promote-catalog.py` |
| Pipeline | GitHub Actions + Ansible | Tekton + IIB |
| Catalog image | `opm serve /configs` | IIB-built per-version images |

Template format and `ci.yaml` schema are **identical** — the same `basic.yaml` or `semver.yaml`
template works in both repos; only the `catalog_names` value differs (`"latest"` here vs `"v4.22"` there).

## Review and merge

FBC contributions follow the same PR process as bundle contributions.
CI validates:
1. `opm validate` on the rendered catalog
2. Consistency between `catalog-templates/` and committed `catalogs/latest/`

See [CONTRIBUTING.md](../README.md) for general submission guidance.
