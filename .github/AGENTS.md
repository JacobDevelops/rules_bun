<!-- Parent: ../AGENTS.md -->
<!-- Generated: 2026-04-20 | Updated: 2026-04-20 -->

# .github

## Purpose
GitHub Actions CI configuration for `rules_bun`. Contains workflows for continuous integration, documentation publishing, and GitHub Copilot setup.

## Subdirectories

| Directory | Purpose |
|-----------|---------|
| `workflows/` | GitHub Actions workflow YAML files |

## Key Files (workflows/)

| File | Description |
|------|-------------|
| `ci.yml` | Main CI workflow — runs `bazel test //tests/...` across platforms |
| `pages.yml` | Docs site deployment — publishes `docs/` to GitHub Pages |
| `copilot-setup-steps.yml` | GitHub Copilot Workspace setup steps |
| `BUILD.bazel` | Bazel package for workflow-related targets |

## For AI Agents

### Working In This Directory
- Do not modify `ci.yml` without verifying the test matrix still covers all supported platforms
- `pages.yml` deploys on push to main — ensure `docs/rules.md` is regenerated before merging rule changes
- Changes to CI should be tested via a PR before merging to main

<!-- MANUAL: -->
