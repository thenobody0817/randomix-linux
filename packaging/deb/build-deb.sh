#!/usr/bin/env bash
# Build a Debian package from the Flutter Linux release bundle.
#
# No root and no debhelper are needed: the tree is assembled by hand and packed
# with dpkg-deb --root-owner-group.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PUBSPEC_VERSION="$(sed -n 's/^version: *\([^+ ]*\).*/\1/p' "$ROOT/pubspec.yaml")"
VERSION="${VERSION:-$PUBSPEC_VERSION}"
REVISION="${REVISION:-1}"
ARCH="$(dpkg --print-architecture)"
BUNDLE="$ROOT/build/linux/x64/release/bundle"
STAGE="$ROOT/build/deb/randomix_${VERSION}-${REVISION}_${ARCH}"
OUT="$ROOT/dist/randomix_${VERSION}-${REVISION}_${ARCH}.deb"

if [[ ! -x "$BUNDLE/randomix" ]]; then
  echo "error: release bundle not found at $BUNDLE" >&2
  echo "       run: make build" >&2
  exit 1
fi

echo "== staging $STAGE"
rm -rf "$ROOT/build/deb"
mkdir -p "$STAGE/DEBIAN" \
         "$STAGE/usr/lib/randomix" \
         "$STAGE/usr/bin" \
         "$STAGE/usr/share/applications" \
         "$STAGE/usr/share/metainfo" \
         "$STAGE/usr/share/doc/randomix"

# The bundle keeps its internal layout: lib/ is found through the binary's
# $ORIGIN/lib RPATH.
cp -a "$BUNDLE/." "$STAGE/usr/lib/randomix/"

cat > "$STAGE/usr/bin/randomix" <<'WRAPPER'
#!/bin/sh
exec /usr/lib/randomix/randomix "$@"
WRAPPER
chmod 0755 "$STAGE/usr/bin/randomix"

install -m 0644 "$ROOT/packaging/io.github.thenobody0817.Randomix.desktop" \
  "$STAGE/usr/share/applications/io.github.thenobody0817.Randomix.desktop"
install -m 0644 "$ROOT/packaging/io.github.thenobody0817.Randomix.metainfo.xml" \
  "$STAGE/usr/share/metainfo/io.github.thenobody0817.Randomix.metainfo.xml"

mkdir -p "$STAGE/usr/share/icons"
cp -a "$ROOT/packaging/icons/hicolor" "$STAGE/usr/share/icons/"

# ---------------------------------------------------------------- docs

{
  cat <<'CONTROL_HEAD'
Format: https://www.debian.org/doc/packaging-manuals/copyright-format/1.0/
Upstream-Name: Randomix
Source: https://github.com/m-i-n-a-r/randomix

Files: *
Copyright: 2020 minar
License: MIT
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 .
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 .
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.

Files: debian/*
Copyright: 2026 thenobody0817
License: MIT
CONTROL_HEAD
} > "$STAGE/usr/share/doc/randomix/copyright"

cat > "$STAGE/usr/share/doc/randomix/changelog" <<CHANGELOG
randomix ($VERSION-$REVISION) unstable; urgency=medium

  * Linux desktop port of Randomix $VERSION (Flutter rewrite).
  * Roulette with options, number ranges, letter/number/card presets and recent sets.
  * Coin flip, dice (D4-D20, 1-10 dice, 3 vs 3) and magic ball with custom answers.
  * Light, dark and Amoled themes, twelve accents, blob background, sounds.
  * English UI, MIT licensed, based on the Android app by minar.

 -- thenobody0817 <thenobody0817@users.noreply.github.com>  $(date -R)
CHANGELOG
gzip -9n -f "$STAGE/usr/share/doc/randomix/changelog"

# ---------------------------------------------------------------- maintainer scripts

cat > "$STAGE/DEBIAN/postinst" <<'POSTINST'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
if command -v gtk-update-icon-cache >/dev/null 2>&1; then
  gtk-update-icon-cache -q -f -t /usr/share/icons/hicolor || true
fi
exit 0
POSTINST
chmod 0755 "$STAGE/DEBIAN/postinst"

cat > "$STAGE/DEBIAN/postrm" <<'POSTRM'
#!/bin/sh
set -e
if command -v update-desktop-database >/dev/null 2>&1; then
  update-desktop-database -q /usr/share/applications || true
fi
exit 0
POSTRM
chmod 0755 "$STAGE/DEBIAN/postrm"

INSTALLED_SIZE="$(du -sk "$STAGE" | cut -f1)"

cat > "$STAGE/DEBIAN/control" <<CONTROL
Package: randomix
Version: $VERSION-$REVISION
Architecture: $ARCH
Maintainer: thenobody0817 <thenobody0817@users.noreply.github.com>
Installed-Size: $INSTALLED_SIZE
Depends: libc6 (>= 2.34), libstdc++6, libgcc-s1, libgtk-3-0t64 | libgtk-3-0, libblkid1, liblzma5, gstreamer1.0-plugins-base, gstreamer1.0-plugins-good
Recommends: gstreamer1.0-libav
Section: utils
Priority: optional
Homepage: https://github.com/m-i-n-a-r/randomix
Description: random decision maker
 Randomix chooses randomly between numbers, answers, options and so on.
 .
 Four tools in one window: a roulette with custom options, number ranges,
 letter, number and card presets plus a recent sets list, a coin flip, dice of
 type D4 to D20 (including 3 vs 3) and a magic ball with custom answers. Light,
 dark and Amoled themes, twelve accent colours and an animated background are
 included.
 .
 This package is a Flutter port of the Android app of the same name.
CONTROL

echo "== building $OUT"
mkdir -p "$ROOT/dist"
rm -f "$OUT"
dpkg-deb --root-owner-group -Zxz --build "$STAGE" "$OUT" >/dev/null
echo "== done: $OUT ($(du -h "$OUT" | cut -f1))"
