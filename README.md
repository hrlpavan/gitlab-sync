# 🦊 GitLab & GitHub Sync Hub (`hrlpavan`)

This private repository is your central configuration, automation vault, and reference guide for keeping **GitHub** (`github.com/hrlpavan`) and **GitLab** (`gitlab.com/hrlpavan`) synchronized, maintaining your daily activity streaks across both platforms, and integrating with **Antigravity MCP**.

---

## ⚡ Quick Status & Architecture

| Component | GitHub | GitLab | Status |
| :--- | :--- | :--- | :--- |
| **Profile** | [github.com/hrlpavan](https://github.com/hrlpavan) | [gitlab.com/hrlpavan](https://gitlab.com/hrlpavan) | Connected |
| **Author Email** | `pavankcet@gmail.com` | `pavankcet@gmail.com` | Configured |
| **SSH Auth** | `~/.ssh/github_signing_key` | `~/.ssh/github_signing_key` | Active (No passwords required) |
| **Antigravity MCP** | `@modelcontextprotocol/server-github` | `@modelcontextprotocol/server-gitlab` | Configured in `mcp_config.json` |

---

## 🚀 Maintaining Your Contribution Streak Across Both

Both GitHub and GitLab grant daily contribution squares when:
1. Commits are pushed to the default branch (or active project branches).
2. The author email inside the Git commit matches an email verified on your profile.

### 1. Push to Both Platforms with One Command
Your machine has a global alias configured: `git dual-sync`.

Whenever you are working in any local Git project, run:
```bash
git dual-sync
```
This automatically configures `origin` so `git push origin main` pushes commits to **both GitHub and GitLab at the exact same second**, lighting up both activity heatmaps.

To check remotes on any repo:
```bash
git remote -v
```
You should see:
```text
origin  git@github.com:hrlpavan/<repo>.git (fetch)
origin  git@github.com:hrlpavan/<repo>.git (push)
origin  git@gitlab.com:hrlpavan/<repo>.git (push)
```

---

## 🔄 Automated Cloud Sync (GitHub Action)

Inside [`.github/workflows/mirror.yml`](.github/workflows/mirror.yml), a GitHub Action automatically mirrors any code pushed to this repository straight to your GitLab repository.

To enable this action on any of your repositories:
1. Go to your GitHub repository **Settings** $\rightarrow$ **Secrets and variables** $\rightarrow$ **Actions**.
2. Click **New repository secret**.
3. Name: `GITLAB_TOKEN`
4. Value: Your GitLab Personal Access Token (`glpat-...`).

---

## 🤖 Antigravity MCP Integration

Both GitLab and GitHub MCP servers are configured in your global configuration file:
`~/.gemini/config/mcp_config.json`

### Available MCP Capabilities:
- **GitLab MCP (`@modelcontextprotocol/server-gitlab`)**:
  - List and inspect GitLab projects, branches, and commits.
  - Create and manage Merge Requests (MRs).
  - Create and browse GitLab issues and milestones.
  - Read files and search across your GitLab account.
- **GitHub MCP (`@modelcontextprotocol/server-github`)**:
  - Inspect repositories, pull requests, and issues.
  - Trigger workflows, create gists, and inspect GitHub actions.

---

## 📚 Key Differences: GitHub vs GitLab

| Feature | GitHub | GitLab |
| :--- | :--- | :--- |
| **Repository Unit** | Repository | **Project** (Repo + Issues + CI/CD + Packages) |
| **Code Review** | Pull Request (PR) | **Merge Request (MR)** |
| **CI/CD Configuration**| `.github/workflows/*.yml` | `.gitlab-ci.yml` |
| **Account Hierarchy** | Users & Organizations | Users, Groups, and Subgroups |
| **Built-in Registry** | GitHub Packages | GitLab Container & Package Registry |
