# 🚀 GitLab & GitHub Unified Sync & Community Contributor Runbook

A complete technical architecture, deep dive, and runbook for **`hrlpavan`** (`pavankcet@gmail.com`) across **GitHub**, **GitLab**, and **Google Antigravity**.

---

## 📌 Table of Contents

1. [Architecture & Dual-Sync Setup](#1-architecture--dual-sync-setup)
2. [First GitLab Community Contribution (Issue #595159 / MR !259119)](#2-first-gitlab-community-contribution)
3. [Under the Hood: Root Causes & How We Fixed Them](#3-under-the-hood-root-causes--how-we-fixed-them)
4. [CI/CD Verification & Pipeline Fact-Check](#4-cicd-verification--pipeline-fact-check)
5. [The "Cannot Merge" UI Indicator Explained](#5-the-cannot-merge-ui-indicator-explained)
6. [Daily Workflow & Commands Cheat Sheet](#6-daily-workflow--commands-cheat-sheet)
7. [Second GitLab Community Contribution (Issue omnibus-gitlab#841 / MR !9851)](#7-second-gitlab-community-contribution-issue-omnibus-gitlab841--mr-9851)
8. [Automated Cross-Project MR Creation via GitLab API](#8-automated-cross-project-mr-creation-via-gitlab-api)

---

## 1. Architecture & Dual-Sync Setup

We connected GitHub and GitLab into a synchronized development environment so that every local commit contributes to both streaks simultaneously without duplicate work.

### 🔑 Single ED25519 SSH Key
A single high-security SSH key on macOS (`~/.ssh/github_signing_key`) authenticates and signs commits on both platforms:
- **Public Key**: `ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFysv4BpovNhwgfwqKGr4xkhvhDmAThnBEgxr9KSCMgG pavankcet@gmail.com`
- **Configured Host Routing (`~/.ssh/config`)**:
  ```ssh
  Host github.com
    IdentityFile ~/.ssh/github_signing_key
    User git

  Host gitlab.com
    IdentityFile ~/.ssh/github_signing_key
    User git
  ```
- **Verified Access**:
  - `ssh -T git@github.com` $\rightarrow$ `Hi hrlpavan! You've successfully authenticated.`
  - `ssh -T git@gitlab.com` $\rightarrow$ `Welcome to GitLab, @hrlpavan!`

### ⚡ The `git dual-sync` Engine
A custom Git global alias automatically configures any repository to push to both GitHub and GitLab with a single `git push`:
```bash
# Inside any repository:
git dual-sync
```

**What it does:**
1. Queries current remote or detects repo directory name.
2. Configures `git remote set-url --add --push origin` for both GitHub and GitLab.
3. Running `git push origin <branch>` sends changes to both remotes in parallel.

### 🤖 Antigravity Model Context Protocol (MCP)
Configured official MCP servers inside `~/.gemini/config/mcp_config.json`:
- **GitLab MCP**: `@modelcontextprotocol/server-gitlab` (authenticated via personal access token with `api` and `write_repository` scopes).
- **GitHub MCP**: `@modelcontextprotocol/server-github` (authenticated via personal access token with repo management scopes).

---

## 2. First GitLab Community Contribution

- **Target Issue**: [GitLab Issue #595159](https://gitlab.com/gitlab-org/gitlab/-/work_items/595159)
- **Feature**: *GitLab MCP Server: Add enum constraint to scope parameter in search tool JSON schema*
- **Active Merge Request**: [GitLab MR !259119](https://gitlab.com/gitlab-org/gitlab/-/merge_requests/259119)
- **Target Repository**: `gitlab-org/gitlab` (Target branch: `master`)
- **Working Branch**: `595159-add-enum-to-mcp-search-scope`

### Why This Feature Matters
The GitLab MCP (Model Context Protocol) Server exposes tools for AI agents (such as GitLab Duo, Claude Desktop, and Antigravity). The `search` tool accepts a `scope` parameter. Previously, the tool schema lacked an `enum` constraint, causing AI models to guess scopes or pass invalid ones. Adding `enum: all_available_search_scopes` enforces schema validation before calls are made.

---

## 3. Under the Hood: Root Causes & How We Fixed Them

During development and CI validation, we encountered 5 distinct engineering challenges. Here is exactly what happened under the hood and how each was resolved:

```
┌────────────────────────────────────────────────────────────────────────┐
│                        Engineering Progression                         │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Storage Quota (Personal Fork Cap) ──► Switch to Community Fork      │
│ 2. Schema Validation Failure ('issues') ─► Update to 'work_items'      │
│ 3. RuboCop LineLength (123 > 120 chars) ─► Format do...end multiline   │
│ 4. EE Schema Mismatch (Missing enum) ──► Match array in EE spec        │
│ 5. Upstream Master Conflict ('eq' lock) ─► Merge eq + enum assertions  │
└────────────────────────────────────────────────────────────────────────┘
```

### Challenge 1: Personal Fork Storage Quota Overrun
- **Symptom**: `Your changes could not be committed, because this repository has exceeded the allocated storage for your project.`
- **Under the Hood**: `gitlab-org/gitlab` is an ~8.5 GiB repository. Free personal GitLab namespaces have a strict 5–10 GiB storage cap. Forking into `hrlpavan/gitlab` immediately exceeded the namespace limit.
- **Root Cause & Fix**: Community contributors must NOT push large forks to personal namespaces. We transitioned to the shared community fork: `gitlab-community/gitlab-org/gitlab` (Project ID: `41372369`), which is enrolled in the GitLab Ultimate Community program with unlimited storage and CI runners.

### Challenge 2: CE RSpec Test Failure on Scope Validation
- **Symptom**: `test rspec unit predictive` failed in pipeline `#2902474590` (8 test failures).
- **Under the Hood**: Existing tests in `spec/services/mcp/tools/search/search_service_spec.rb` passed `scope: 'issues'`. When we introduced `enum: all_available_search_scopes`, strict JSON schema validation rejected `'issues'`.
- **Root Cause & Fix**: In `SearchService`, `all_available_search_scopes` delegates to `Search::GlobalService.new.allowed_scopes(include_api_only: false)`. The `'issues'` scope is an API-only backward-compatibility alias; the standard search scope is `'work_items'`. We updated test mocks from `'issues'` to `'work_items'` and added negative assertions for `'invalid_scope'`.

### Challenge 3: RuboCop Line Length Violations
- **Symptom**: RuboCop failed on line 121 of `search_service_spec.rb`.
- **Under the Hood**: `Layout/LineLength: Line is too long. [123/120]`.
- **Root Cause & Fix**: The one-line declaration `let(:arguments) { { query: 'test', scope: 'work_items', group_id: 1, project_id: 2 } }` exceeded the 120-character limit. We refactored it into a clean multiline `do...end` block complying with GitLab Ruby style conventions.

### Challenge 4: EE Predictive Spec Schema Mismatch
- **Symptom**: Pipeline `#2902540585` failed on `ee/spec/services/ee/mcp/tools/search/search_service_spec.rb` (1 failure).
- **Under the Hood**: GitLab Enterprise Edition (EE) overrides the MCP search tool schema to inject advanced Elasticsearch / Zoekt search properties. The EE test assertively checked the schema properties, which lacked our newly added `enum:` array.
- **Root Cause & Fix**: Updated `ee/spec/services/ee/mcp/tools/search/search_service_spec.rb` to include `enum: match_array(all_available_search_scopes)` across both `base_schema` and `advanced_search_properties`.

### Challenge 5: Upstream Merge Conflict on Master Rebase
- **Symptom**: Rebase on upstream master caused pipeline `#2905146921` to fail.
- **Under the Hood**: While our MR was running, upstream master merged commit `b38e46c5602d` (*"Lock the full input schema of every MCP tool in specs"*). This commit changed CE `#input_schema` expectations from loose `match` to strict `eq` comparisons.
- **Root Cause & Fix**: We resolved the rebase conflict by combining both requirements: retaining the strict `eq` schema structure from master while ensuring `enum: all_available_search_scopes` was included. Branch was safely backed up to `duo-developer-backup/595159-add-enum-to-mcp-search-scope`.

---

## 4. CI/CD Verification & Pipeline Fact-Check

We verified all jobs directly against the GitLab GraphQL and REST APIs.

### Pipeline Summary:
| Pipeline ID | Commit | State | Results & Key Jobs |
| :--- | :--- | :--- | :--- |
| `#2902474590` | `5f9dadd4` | Failed | 8 CE test failures (`scope: 'issues'` vs enum) |
| `#2902540585` | `229d61cc` | Failed | 1 EE test failure (schema mismatch) |
| `#2905146921` | `754ab7d5` | Failed | Master rebase conflict with `b38e46c5602d` |
| **`#2905161468`** | `99404e41` | Running | Triggered by MR update event |
| **`#2905161530`** (Head) | `99404e41` | Running | Head pipeline containing all fixes |

### Live Job Results for Head Commit (`99404e41`):
- **`rubocop`**: **SUCCESS** (108s) — 0 lint violations.
- **`danger-review`**: **SUCCESS** (82s) — Automated preflight guidelines passed.
- **`rspec unit predictive`** (Downstream `#2905186534`): **SUCCESS (100% Passed)**.
- **`rspec-ee unit predictive`** (Downstream `#2905186535`): **SUCCESS (100% Passed)**.
- **`pajamas_adoption`**: Soft failed (`allow_failure: true`) due to git fetch timeout inside runner; non-blocking.
- **`has_conflicts`**: **False** (clean merge target).

---

## 5. The "Cannot Merge" UI Indicator Explained

When viewing the MR in GitLab, a tooltip displays:
> ⚠️ **Cannot merge**

### Why This Is Normal (Not a Bug):
We queried the MR mergeability payload via the GitLab API:
```json
{
  "merge_status": "can_be_merged",
  "has_conflicts": false,
  "user": { "can_merge": false },
  "detailed_merge_status": "not_approved",
  "approvals_required": 4,
  "approvals_left": 4,
  "approval_rules_left": [
    { "name": "/app/", "rule_type": "code_owner" },
    { "name": "app/services/mcp/tools/", "rule_type": "code_owner" },
    { "name": "/ee/spec/", "rule_type": "code_owner" },
    { "name": "/spec/", "rule_type": "code_owner" }
  ]
}
```

1. **`user.can_merge: false`**: The `gitlab-org/gitlab:master` branch is protected. External community contributors cannot click "Merge". Merging must be performed by a GitLab Maintainer.
2. **`approvals_left: 4`**: GitLab's CODEOWNERS policy requires approval from code owners across `/app/`, `app/services/mcp/tools/`, `/ee/spec/`, and `/spec/`.
3. **`merge_status: can_be_merged`**: Git can merge the code cleanly with zero conflicts.

---

## 6. Daily Workflow & Commands Cheat Sheet

### Dual-Pushing Changes
```bash
# Inside any repository configured with dual-sync:
git add .
git commit -m "feat: description of work"
git push origin main
```
*This pushes to GitHub and GitLab simultaneously, maintaining both contribution streaks.*

### Requesting Review on GitLab MR
When all tests are green, signal to GitLab Community Coaches and Reviewer Roulette that your MR is ready:
```text
/label ~"workflow::ready for review"
```
Or manage via the [GitLab Contributor Portal](https://contributors.gitlab.com/manage-issue).

---

## 7. Second GitLab Community Contribution (Issue omnibus-gitlab#841 / MR !9851)

- **Target Issue**: [GitLab Issue omnibus-gitlab#841](https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/841)
- **Title**: *Document how to use the Docker image with self-signed certificate + Mattermost*
- **Active Merge Request**: [GitLab MR !9851](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9851)
- **Target Repository**: `gitlab-org/omnibus-gitlab` (Target branch: `master`)
- **Community Source Remote**: `gitlab.com/gitlab-community/gitlab-org/omnibus-gitlab.git` (Branch: `hrlpavan-doc-mattermost-docker-ssl`)

### Engineering Context & Root Cause
When running GitLab in a Docker container configured with a custom or self-signed SSL/TLS certificate, integrating with external services like Mattermost fails during TLS handshake validation with:
```plaintext
x509: certificate signed by unknown authority
```
- **Why this occurs**: Mattermost is written in Go. Go's native `crypto/tls` runtime inspects the operating system root CA certificate store (`/etc/ssl/certs/ca-certificates.crt`). Adding custom certificates only to `/opt/gitlab/embedded/ssl/certs/` (used by GitLab's internal OpenSSL) does not automatically update Debian's system-level trust bundle inside the container.
- **The Solution Documented**:
  Added comprehensive troubleshooting guidance in [`doc/settings/ssl/ssl_troubleshooting.md`](https://gitlab.com/gitlab-org/omnibus-gitlab/-/blob/master/doc/settings/ssl/ssl_troubleshooting.md) under `## Mattermost with a self-signed certificate in a Docker container`:
  1. Inspect container logs with `docker logs gitlab` to confirm `x509: certificate signed by unknown authority`.
  2. Copy the self-signed certificate into `/usr/local/share/ca-certificates/` inside the container.
  3. Execute `update-ca-certificates` (or `dpkg-reconfigure ca-certificates`) to rebuild the system bundle.
  4. Ensure the certificate is also added to `/etc/gitlab/trusted-certs/` for GitLab's internal OpenSSL.
  5. Run `gitlab-ctl reconfigure` and `gitlab-ctl restart`.

### Danger Bot & CI/CD Review Progression
During automated preflight review, GitLab's Danger bot and CI pipelines enforced strict contributing policies:
1. **Commit Subject Capitalization**: Changed commit subject from lowercase `docs: ...` to uppercase `Document Mattermost self-signed certificate handling in Docker`.
2. **Full Reference URLs**: Replaced short issue shorthand `#841` with the full canonical URL `Closes https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/841`.
3. **CI Linters (100% Passed)**:
   - `docs-lint content` (Vale prose style guide compliance): **Passed**
   - `docs-lint markdown` (Markdownlint syntax): **Passed**
   - `docs-lint links` (Lychee broken links check): **Passed**
   - `docs-lint hugo` (Hugo documentation compiler): **Passed**
   - `danger-review`: **0 Errors**

---

## 8. Automated Cross-Project MR Creation via GitLab API

Because GitLab community contributors develop in the shared community fork (`gitlab-community/gitlab-org/omnibus-gitlab`), opening an upstream Merge Request targeting canonical `gitlab-org/omnibus-gitlab` can hit 404s in the web UI when routes differ.

We automated the submission using the GitLab REST API with our authenticated Personal Access Token:
```bash
curl -X POST \
  -H "PRIVATE-TOKEN: <GITLAB_PAT>" \
  -H "Content-Type: application/json" \
  -d '{
    "source_branch": "hrlpavan-doc-mattermost-docker-ssl",
    "target_branch": "master",
    "target_project_id": 20699,
    "title": "Document Mattermost self-signed certificate handling in Docker",
    "description": "## What does this MR do and why?\n\nDocuments how to configure self-signed SSL certificates with Mattermost in a GitLab Docker container to resolve `x509: certificate signed by unknown authority` errors.\n\nCloses https://gitlab.com/gitlab-org/omnibus-gitlab/-/work_items/841"
  }' \
  "https://gitlab.com/api/v4/projects/44355627/merge_requests"
```
- **Source Project ID (`44355627`)**: `gitlab-community/gitlab-org/omnibus-gitlab` (where the branch lives).
- **Target Project ID (`20699`)**: `gitlab-org/omnibus-gitlab` (upstream canonical repo).
- **Result**: Immediate creation of upstream Merge Request **[!9851](https://gitlab.com/gitlab-org/omnibus-gitlab/-/merge_requests/9851)** with automatic linkage to Work Item #841.

---

*Authored by **Pavan Kumar Sadashiv** (`@hrlpavan`)*
