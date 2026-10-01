#!/usr/bin/env bash
#
# Quick sync utility for hrlpavan
# Ensures both GitHub and GitLab have all branches and tags
#

set -e

REPO_NAME=$(basename "$(git rev-parse --show-toplevel)")
echo "🔄 Synchronizing $REPO_NAME between GitHub and GitLab..."

# Ensure remotes exist
git remote set-url --add --push origin "git@github.com:hrlpavan/${REPO_NAME}.git" 2>/dev/null || true
git remote set-url --add --push origin "git@gitlab.com:hrlpavan/${REPO_NAME}.git" 2>/dev/null || true

# Fetch all updates
echo "📥 Fetching latest from origin..."
git fetch origin

# Push all branches and tags to both remotes
CURRENT_BRANCH=$(git branch --show-current)
echo "🚀 Pushing branch '$CURRENT_BRANCH' to GitHub and GitLab..."
git push origin "$CURRENT_BRANCH"

echo "✅ Dual-sync complete!"
