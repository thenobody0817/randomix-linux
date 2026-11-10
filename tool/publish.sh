#!/usr/bin/env bash
# Publish the repository, tag and release to GitHub.
#
# Prerequisites:
#   tool/download-gh.sh          # local gh, no root
#   .tooling/gh/bin/gh auth login
#   make deb                     # builds dist/randomix_<version>-1_<arch>.deb
#
# The git credential helper is written inside .tooling/ and asks gh for the
# token on demand, so no credential is stored in the repository or in ~/.gitconfig.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GH="${GH:-$ROOT/.tooling/gh/bin/gh}"
OWNER="${OWNER:-thenobody0817}"
REPO="${REPO:-randomix-linux}"
VERSION="${VERSION:-4.0.0}"
TAG="v$VERSION"
DEB="$ROOT/dist/randomix_${VERSION}-1_amd64.deb"
DESCRIPTION="Randomix for Linux — a Flutter port of the Android random decision maker"

if [[ ! -x "$GH" ]]; then
  echo "error: gh not found at $GH (run tool/download-gh.sh)" >&2
  exit 1
fi
if ! "$GH" auth status >/dev/null 2>&1; then
  echo "error: not logged in (run $GH auth login)" >&2
  exit 1
fi
if [[ ! -d "$ROOT/.git" ]]; then
  echo "error: $ROOT is not a git repository" >&2
  exit 1
fi
if [[ ! -f "$DEB" ]]; then
  echo "error: $DEB missing (run make deb)" >&2
  exit 1
fi

echo "== configuring a repository-local credential helper"
HELPER="$ROOT/.tooling/gh/git-credential-gh"
cat > "$HELPER" <<EOF
#!/bin/sh
if [ "\$1" = get ]; then
  echo username=$OWNER
  printf 'password=%s\n' "\$("$GH" auth token)"
fi
EOF
chmod 0700 "$HELPER"
git -C "$ROOT" config --local credential.helper "$HELPER"

if ! git -C "$ROOT" remote get-url origin >/dev/null 2>&1; then
  git -C "$ROOT" remote add origin "https://github.com/$OWNER/$REPO.git"
fi

echo "== creating the repository if needed"
if ! "$GH" repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  "$GH" repo create "$OWNER/$REPO" --public \
    --description "$DESCRIPTION" \
    --homepage "https://github.com/$OWNER/$REPO"
else
  echo "   $OWNER/$REPO already exists"
fi

echo "== pushing main"
git -C "$ROOT" push -u origin main

echo "== tagging $TAG"
if ! git -C "$ROOT" rev-parse "$TAG" >/dev/null 2>&1; then
  git -C "$ROOT" tag -a "$TAG" -m "Randomix $VERSION for Linux"
fi
git -C "$ROOT" push origin "$TAG"

echo "== creating the release"
if ! "$GH" release view "$TAG" --repo "$OWNER/$REPO" >/dev/null 2>&1; then
  "$GH" release create "$TAG" "$DEB" \
    --repo "$OWNER/$REPO" \
    --title "Randomix $VERSION for Linux" \
    --notes-file "$ROOT/packaging/release-notes.md"
else
  echo "   release $TAG exists, updating the asset"
  "$GH" release upload "$TAG" "$DEB" --repo "$OWNER/$REPO" --clobber
fi

echo "== published: https://github.com/$OWNER/$REPO"
