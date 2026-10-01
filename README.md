# 🚀 GitLab & GitHub Unified Sync & Antigravity MCP Setup

A complete log and runbook of everything configured in this session for **`hrlpavan`** (`pavankcet@gmail.com`) across **GitHub**, **GitLab**, and **Antigravity**.

---

## 📌 Executive Summary

In this session, we linked your GitHub and GitLab ecosystems together so that:
1. **Contribution Streaks**: Any code you push locally lights up **both** your GitHub and GitLab contribution graphs simultaneously.
2. **Passwordless SSH**: A single SSH key on your Mac authenticates seamlessly to both GitHub and GitLab without password prompts.
3. **Automated Dual-Sync**: A custom global command (`git dual-sync`) enables 1-step dual-pushing for any repository.
4. **Antigravity MCP Integration**: Configured Model Context Protocol (MCP) servers for both GitLab and GitHub directly inside Antigravity.
5. **Private Companion Hub**: Created and synced the `gitlab-sync` private repository across both platforms.

---

## 1. 👤 Account & Streak Alignment

Contribution graphs on both platforms count commits based on the **author email** in the commit metadata.

- **Local Git Identity Configured**:
  ```bash
  git config --global user.name "hrlpavan"
  git config --global user.email "pavankcet@gmail.com"
  ```
- **Profiles Linked**:
  - **GitHub**: [github.com/hrlpavan](https://github.com/hrlpavan)
  - **GitLab**: [gitlab.com/hrlpavan](https://gitlab.com/hrlpavan)
  - Both accounts have `pavankcet@gmail.com` verified, guaranteeing that all commits increment both streaks simultaneously.

---

## 2. 🔑 SSH Authentication Setup

Your Mac's ED25519 key (`~/.ssh/github_signing_key`) was provisioned and authorized across both platforms:

- **Public Key**:
  ```text
  ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFysv4BpovNhwgfwqKGr4xkhvhDmAThnBEgxr9KSCMgG pavankcet@gmail.com
  ```
- **Platform Authorization**:
  - Registered on **GitLab** as authentication & signing key.
  - Registered on **GitHub** via API under `MacBook Pro Antigravity`.
- **SSH Host Configuration (`~/.ssh/config`)**:
  Configured host mappings to route both `github.com` and `gitlab.com` through `~/.ssh/github_signing_key`.
- **Verified Status**:
  - `ssh -T git@github.com` $\rightarrow$ `Hi hrlpavan! You've successfully authenticated.`
  - `ssh -T git@gitlab.com` $\rightarrow$ `Welcome to GitLab, @hrlpavan!`

---

## 3. ⚡ The `git dual-sync` Shortcut

A global Git alias was installed to eliminate manual remote configuration.

### How to use it on any repo:
```bash
# Inside any project on your computer:
git dual-sync
```

### What it does automatically:
1. Detects the project name.
2. Configures `origin` push targets for both `git@github.com:hrlpavan/<repo>.git` and `git@gitlab.com:hrlpavan/<repo>.git`.
3. Displays the verified dual-push configuration:
   ```text
   origin  git@github.com:hrlpavan/project.git (fetch)
   origin  git@github.com:hrlpavan/project.git (push)
   origin  git@gitlab.com:hrlpavan/project.git (push)
   ```

Now, running a standard push updates both services in one shot:
```bash
git push origin main
```

---

## 4. 🤖 Antigravity MCP Integration

Both official MCP servers are active in `~/.gemini/config/mcp_config.json`:

| Service | MCP Package | Capabilities |
| :--- | :--- | :--- |
| **GitLab** | `@modelcontextprotocol/server-gitlab` | Manage GitLab projects, files, branches, merge requests, issues |
| **GitHub** | `@modelcontextprotocol/server-github` | Inspect GitHub repos, pull requests, issues, and workflows |

### Server Configuration in `~/.gemini/config/mcp_config.json`:
```json
{
  "mcpServers": {
    "gitlab": {
      "command": "/Users/pavankumars/.nvm/versions/node/v24.19.0/bin/npx",
      "args": ["-y", "@modelcontextprotocol/server-gitlab"],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "glpat-REDACTED_FOR_SECURITY",
        "GITLAB_API_URL": "https://gitlab.com/api/v4"
      }
    },
    "github": {
      "command": "/Users/pavankumars/.nvm/versions/node/v24.19.0/bin/npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_PERSONAL_ACCESS_TOKEN": "ghp_***"
      }
    }
  }
}
```

---

## 5. 📦 Created Repositories & Automation Files

The `gitlab-sync` private repository was created and initialized simultaneously on both platforms:
- **GitHub**: [github.com/hrlpavan/gitlab-sync](https://github.com/hrlpavan/gitlab-sync)
- **GitLab**: [gitlab.com/hrlpavan/gitlab-sync](https://gitlab.com/hrlpavan/gitlab-sync)

### Files in this repository:
- **`README.md`**: Complete architecture guide and session log.
- **`.github/workflows/mirror.yml`**: GitHub Actions workflow that automatically mirrors commits from GitHub to GitLab if you commit via web/cloud.
- **`.gitlab-ci.yml`**: Native GitLab CI/CD pipeline template.
- **`scripts/sync-all.sh`**: Helper script to synchronize all branches and tags between remotes.

---

## 6. 🧠 Cheat Sheet: GitHub vs GitLab

| Feature | GitHub | GitLab |
| :--- | :--- | :--- |
| **Repository Unit** | Repository | **Project** (Repo + Issues + CI/CD + Packages) |
| **Code Review** | Pull Request (PR) | **Merge Request (MR)** |
| **CI/CD File** | `.github/workflows/*.yml` | `.gitlab-ci.yml` |
| **Hierarchy** | Organizations & Teams | **Groups & Subgroups** (Nested namespaces) |
| **Streaks** | Default branch / gh-pages commits | All project branch commits & MRs |
