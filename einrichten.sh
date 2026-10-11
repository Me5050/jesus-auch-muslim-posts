#!/usr/bin/env bash
# Einmalige Einrichtung: Repository anlegen, Label erstellen, Claude-API-Schlüssel hinterlegen.
# Aufruf: ./einrichten.sh            (öffentliches Repository)
#         ./einrichten.sh --private  (privates Repository)
# Voraussetzung: GitHub CLI (https://cli.github.com) und git.
set -euo pipefail
cd "$(dirname "$0")"
NAME="jesus-auch-muslim-posts"
SICHT="--public"; [ "${1:-}" = "--private" ] && SICHT="--private"

gh auth status >/dev/null 2>&1 || gh auth login
gh auth setup-git
if [ -z "$(git config user.email 2>/dev/null || true)" ]; then
  LOGIN=$(gh api user -q .login); ID=$(gh api user -q .id)
  git config --global user.name "$LOGIN"
  git config --global user.email "${ID}+${LOGIN}@users.noreply.github.com"
fi
if [ ! -d .git ]; then
  git init -q -b main
  git add .
  git commit -qm "Post-Generator: Vorlagen, Formular und Workflow"
fi
gh repo create "$NAME" $SICHT --source . --remote origin --push \
  --description "Instagram-Posts für Jesus auch Muslim – Formular, Claude-Prüfung, automatisches Rendern"
gh label create post --color 1D1F3E --description "Formular für neue Instagram-Posts" --force >/dev/null

echo ""
echo "Jetzt den Claude-API-Schlüssel einfügen (aus console.anthropic.com → API Keys):"
gh secret set ANTHROPIC_API_KEY

URL=$(gh repo view "$NAME" --json url -q .url)
echo ""
echo "Fertig: $URL"
echo "Neuer Post: $URL/issues/new?template=neuer-post.yml"
