#!/usr/bin/env bash
# Download a local GitHub CLI into .tooling/gh, without root.
#
# Used only for publishing this repository; the app itself never needs gh.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DEST="$ROOT/.tooling/gh"

TAG="$(curl -fsSL https://api.github.com/repos/cli/cli/releases/latest \
  | sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p')"
if [[ -z "$TAG" ]]; then
  echo "error: could not resolve the latest gh release" >&2
  exit 1
fi

echo "== downloading gh $TAG"
mkdir -p "$DEST"
curl -fSL --retry 2 -o "$DEST/gh.tar.gz" \
  "https://github.com/cli/cli/releases/download/v${TAG}/gh_${TAG}_linux_amd64.tar.gz"
tar -xzf "$DEST/gh.tar.gz" -C "$DEST" --strip-components=1
rm -f "$DEST/gh.tar.gz"

"$DEST/bin/gh" --version | head -1
echo "== done. Log in with: .tooling/gh/bin/gh auth login"
