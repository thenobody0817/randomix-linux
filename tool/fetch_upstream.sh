#!/usr/bin/env bash
# Download the upstream Randomix assets and resources this port uses.
# Upstream: https://github.com/m-i-n-a-r/randomix (MIT, Copyright (c) 2020 minar)
# Run once; everything lands in assets/ and tool/upstream/.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
RAW="https://raw.githubusercontent.com/m-i-n-a-r/randomix/master"
UP="$ROOT/tool/upstream"
mkdir -p "$ROOT/assets/sounds" "$ROOT/assets/images" "$UP"

get() { # get <remote-path> <local-path>
  echo "  fetching $1"
  curl -fsSL --retry 3 -o "$2" "$1"
}

echo "== sounds =="
get "$RAW/app/src/main/res/raw/roulette_sound.mp3"  "$ROOT/assets/sounds/roulette.mp3"
get "$RAW/app/src/main/res/raw/coin_sound.wav"      "$ROOT/assets/sounds/coin.wav"
get "$RAW/app/src/main/res/raw/magicball_sound.mp3" "$ROOT/assets/sounds/magicball.mp3"
get "$RAW/app/src/main/res/raw/dice_sound.wav"      "$ROOT/assets/sounds/dice.wav"

echo "== images =="
get "$RAW/app/src/main/res/drawable-nodpi/intro_icon.png" "$ROOT/assets/images/intro_icon.png"
get "$RAW/app/src/main/res/drawable-nodpi/banner_minar.png" "$ROOT/assets/images/banner.png"
get "$RAW/fastlane/metadata/android/en-US/images/icon.png" "$ROOT/assets/images/icon_512.png"

echo "== strings + license =="
get "$RAW/app/src/main/res/values/strings.xml" "$UP/strings.xml"
get "$RAW/LICENSE.md" "$ROOT/LICENSE.upstream.md"

echo "== done =="
ls -lh "$ROOT/assets/sounds" "$ROOT/assets/images"
