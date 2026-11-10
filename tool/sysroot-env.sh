#!/usr/bin/env bash
# Optional build path that does NOT require root: a private sysroot made from
# the -dev packages that Flutter needs, extracted under .tooling/sysroot.
#
# Use it only when the system packages are missing AND you cannot install them:
#     source tool/sysroot-env.sh
#     flutter build linux --release
#
# The normal, supported path is `apt install ninja-build pkg-config libgtk-3-dev
# libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev` (see README).
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYSROOT="$ROOT/.tooling/sysroot"
if [[ ! -x "$SYSROOT/usr/bin/pkgconf" ]]; then
  echo "error: no sysroot at $SYSROOT (see tool/setup-sysroot.sh)" >&2
  return 1 2>/dev/null || exit 1
fi

mkdir -p "$ROOT/.tooling/bin"
cat > "$ROOT/.tooling/bin/pkg-config" <<WRAPPER
#!/bin/sh
LD_LIBRARY_PATH="$SYSROOT/usr/lib/x86_64-linux-gnu\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}" \\
  exec "$SYSROOT/usr/bin/pkgconf" "\$@"
WRAPPER
chmod +x "$ROOT/.tooling/bin/pkg-config"
ln -sfn "$SYSROOT/usr/bin/ninja" "$ROOT/.tooling/bin/ninja"

export PATH="$ROOT/.tooling/bin:$SYSROOT/usr/bin:$PATH"
export PKG_CONFIG_LIBDIR="$SYSROOT/usr/lib/x86_64-linux-gnu/pkgconfig:$SYSROOT/usr/share/pkgconfig:/usr/lib/x86_64-linux-gnu/pkgconfig:/usr/share/pkgconfig"
export PKG_CONFIG_PATH=""
unset PKG_CONFIG_SYSROOT_DIR
export LDFLAGS="-L$SYSROOT/usr/lib/x86_64-linux-gnu${LDFLAGS:+ $LDFLAGS}"
echo "sysroot environment ready: $(pkg-config --modversion gtk+-3.0 2>/dev/null || echo 'gtk not found')"
