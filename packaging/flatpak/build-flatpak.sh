#!/usr/bin/env bash
# Build and install the Flatpak from the Flutter release bundle.
#
# Everything happens in the user installation: no root, no system changes.
# The runtime is org.freedesktop.Platform 25.08; the builder itself is the
# official org.flatpak.Builder Flatpak.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MANIFEST="$ROOT/packaging/flatpak/io.github.thenobody0817.Randomix.yml"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
BUILD_DIR="$ROOT/build/flatpak-build"
REPO_DIR="$ROOT/build/flatpak-repo"
RUNTIME_VERSION=25.08

if [[ ! -x "$BUNDLE/randomix" ]]; then
  echo "error: release bundle not found at $BUNDLE" >&2
  echo "       run: make build" >&2
  exit 1
fi

if ! command -v flatpak >/dev/null 2>&1; then
  echo "error: flatpak is not installed" >&2
  exit 1
fi

echo "== flathub remote"
flatpak remote-add --user --if-not-exists flathub \
  https://flathub.org/repo/flathub.flatpakrepo

echo "== builder and SDK"
if ! flatpak info org.flatpak.Builder >/dev/null 2>&1; then
  flatpak install -y --user flathub org.flatpak.Builder
fi
if ! flatpak info "org.freedesktop.Sdk//$RUNTIME_VERSION" >/dev/null 2>&1; then
  flatpak install -y --user flathub "org.freedesktop.Sdk//$RUNTIME_VERSION"
fi

# Sound effects need the GStreamer plugins; they live in a runtime extension.
# Best effort: the app degrades to silent if they cannot be installed.
for ext in org.freedesktop.Platform.GStreamer.gst-plugins-good \
           org.freedesktop.Platform.GStreamer.gst-libav; do
  flatpak info "$ext//$RUNTIME_VERSION" >/dev/null 2>&1 ||
    flatpak install -y --user flathub "$ext//$RUNTIME_VERSION" || true
done

echo "== building with flatpak-builder"
flatpak run \
  --filesystem="$ROOT" \
  --share=network \
  org.flatpak.Builder \
  --user --install --force-clean \
  --repo="$REPO_DIR" \
  "$BUILD_DIR" \
  "$MANIFEST"

echo "== done. Launch with: flatpak run io.github.thenobody0817.Randomix"
