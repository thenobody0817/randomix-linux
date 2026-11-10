#!/usr/bin/env bash
# Build .tooling/sysroot from the Debian packages Flutter needs, without root.
#
# This is a fallback for machines where the -dev packages cannot be installed.
# It downloads only the missing packages apt would install, extracts them into a
# private prefix, points the .pc files at that prefix and repairs the linker
# symlinks against the runtime libraries that are already installed.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYSROOT="$ROOT/.tooling/sysroot"
DEBS="$ROOT/.tooling/debs"
PACKAGES=(ninja-build pkg-config libgtk-3-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev)

mkdir -p "$SYSROOT" "$DEBS"

echo "== resolving missing packages"
apt-get install --print-uris -y --no-install-recommends "${PACKAGES[@]}" 2>/dev/null \
  | grep -oE "'http[^']+'" | tr -d "'" | sort -u > "$DEBS/urls.txt"
sed -E 's#.*/##; s#\.deb$##' "$DEBS/urls.txt" | cut -d_ -f1 | sort -u > "$DEBS/names.txt"
echo "   $(wc -l < "$DEBS/names.txt") packages"

echo "== downloading"
while read -r url; do
  file="$DEBS/$(basename "$url")"
  [[ -f "$file" ]] && continue
  curl -fsSL --retry 2 -o "$file" "$url" || echo "   http mirror refused, will use apt: $(basename "$url")"
done < "$DEBS/urls.txt"
missing=()
while read -r name; do
  compgen -G "$DEBS/${name}_*.deb" >/dev/null || missing+=("$name")
done < "$DEBS/names.txt"
if ((${#missing[@]})); then
  (cd "$DEBS" && apt-get download "${missing[@]}" >/dev/null)
fi

echo "== extracting into $SYSROOT"
for deb in "$DEBS"/*.deb; do dpkg-deb -x "$deb" "$SYSROOT"; done

echo "== repairing linker symlinks against the installed runtime libraries"
libdir="$SYSROOT/usr/lib/x86_64-linux-gnu"
while IFS= read -r link; do
  target="$(basename "$(readlink "$link")")"
  if [[ -e "/usr/lib/x86_64-linux-gnu/$target" ]]; then
    ln -sfn "/usr/lib/x86_64-linux-gnu/$target" "$link"
  fi
done < <(find "$libdir" -xtype l 2>/dev/null || true)

echo "== rewriting .pc prefixes to the private sysroot"
python3 - "$SYSROOT" <<'PY'
import pathlib, re, sys
root = pathlib.Path(sys.argv[1])
changed = 0
for pc in root.rglob('*.pc'):
    text = pc.read_text(errors='replace')
    new = re.sub(
        r'^(prefix|exec_prefix|libdir|includedir|datarootdir|datadir|bindir)=(/usr(?:/[^\n]*)?)$',
        lambda m: f"{m.group(1)}={root}/usr" + (m.group(2)[4:] if len(m.group(2)) > 4 else ''),
        text, flags=re.M)
    if new != text:
        pc.write_text(new)
        changed += 1
print(f"   rewrote {changed} .pc files")
PY

echo "== done. Source tool/sysroot-env.sh before building."
