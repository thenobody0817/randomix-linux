#!/usr/bin/env bash
# Sandbox-safe environment for building the Linux port.
# Everything the toolchain writes stays inside .tooling/, so no approval prompts
# are needed and the user's home directory is never touched.
#
# Usage:  source tool/env.sh
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export FLUTTER_ROOT="$ROOT/.tooling/flutter"
export PUB_CACHE="$ROOT/.tooling/pub-cache"
export HOME="$ROOT/.tooling/home"
export XDG_CONFIG_HOME="$ROOT/.tooling/config"
export XDG_CACHE_HOME="$ROOT/.tooling/cache"
export XDG_DATA_HOME="$ROOT/.tooling/data"
export PATH="$FLUTTER_ROOT/bin:$PATH"
mkdir -p "$HOME" "$XDG_CONFIG_HOME" "$XDG_CACHE_HOME" "$XDG_DATA_HOME" "$PUB_CACHE"
