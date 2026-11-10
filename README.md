# Randomix for Linux

> An open source app to choose randomly between numbers, answers, options and so on.
> This repository is a **Linux desktop port** of the Android app
> [m-i-n-a-r/randomix](https://github.com/m-i-n-a-r/randomix), written in Flutter
> and packaged for Debian-based distributions and Flatpak.

**Repository:** https://github.com/thenobody0817/randomix-linux ·
**App id:** `io.github.thenobody0817.Randomix` ·
**Download:** see [Releases](https://github.com/thenobody0817/randomix-linux/releases) for the `.deb`.

The original app is MIT licensed, Copyright (c) 2020 minar. All credits for the
design, the texts, the sounds and the concept belong upstream; see
[LICENSE.upstream.md](LICENSE.upstream.md) and [assets/NOTICE](assets/NOTICE).

## What it does

Four randomizers share one window, with the same rules as the Android app:

| Tool | Behavior |
|---|---|
| **Roulette** | Options mode (up to 30 chips, duplicate protection, optional auto-remove of the winner) or Range mode (inclusive integer range, `min < max`). Presets for `A–Z`, `1–100` and a 52-card deck. Recent option sets: restore, pin, delete, 10 sets max. |
| **Coin** | Heads or tails, 1.5 s flip, 2 s cooldown, streak messages at 3, 5, 10 and 20. |
| **Dice** | D4, D6, D8, D10, D12, D20, one to ten dice, plus the 3 vs 3 mode (six D6, two team sums). Pip face for a single D6. |
| **Magic Ball** | 30 default answers, 6 optional rude answers, or your own answers (semicolon separated, at least two). |

Around them:

- Light, dark and Amoled themes; 12 accent colours (the upstream palette) plus the
  desktop accent where the system exposes one; animated blob background.
- Sound effects (toggle), descriptions toggle, equal options, remove-last-chosen,
  last used page remembered, first-run introduction, about page with links.
- Keyboard: **Space** throws the active tool.
- Responsive layout: bottom navigation bar on narrow windows, navigation rail on
  wide ones, like the phone/tablet split of the original.
- English UI. Strings live in one file (`lib/strings.dart`) and are transcribed
  from the upstream `values/strings.xml`, ready for a locale table later.

## Install

### Debian package

Download `randomix_4.0.0-1_amd64.deb` from the
[releases page](https://github.com/thenobody0817/randomix-linux/releases) and
install it:

```bash
sudo apt install ./randomix_4.0.0-1_amd64.deb
```

Or build it yourself with `make deb` (see below); the artifact lands in `dist/`.

The package installs the Flutter bundle under `/usr/lib/randomix`, a launcher in
`/usr/bin/randomix`, the desktop entry, the AppStream metadata and hicolor icons.
Remove it with `sudo apt remove randomix`.

### Flatpak (user installation, no root)

```bash
make flatpak                  # builds and installs with org.flatpak.Builder
flatpak run io.github.thenobody0817.Randomix
```

The manifest is `packaging/flatpak/io.github.thenobody0817.Randomix.yml` and uses
`org.freedesktop.Platform//25.08`. It packages the release bundle produced by
`flutter build linux --release`; for a Flathub-ready build the Flutter SDK would
have to be vendored or built inside the sandbox (see `flatpak-flutter`).

## Build from source

### 1. System prerequisites

Flutter's Linux target needs GTK 3 development headers, Ninja and pkg-config,
plus the GStreamer headers for the sound plugin:

```bash
sudo apt update
sudo apt install -y ninja-build pkg-config libgtk-3-dev \
                    libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev
```

Clang, CMake and a C++ toolchain are also required; Debian, Ubuntu and PikaOS
already ship them.

If you cannot install those packages (no root, locked-down machine), there is a
private fallback that needs no privileges:

```bash
bash tool/setup-sysroot.sh      # extracts the -dev debs into .tooling/sysroot
source tool/sysroot-env.sh      # points pkg-config, ninja and the linker at it
flutter build linux --release
```

The packages still have to be downloadable from the configured apt repositories.
This path produced the release used by the `.deb` in this repository; the normal
`apt install` route is preferred because it keeps the sysroot out of the loop.

### 2. Flutter SDK

The repository keeps its toolchain in `.tooling/` so the build never writes
outside the checkout:

```bash
mkdir -p .tooling
curl -fL -o .tooling/flutter.tar.xz \
  https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.47.9-stable.tar.xz
tar -xf .tooling/flutter.tar.xz -C .tooling
rm .tooling/flutter.tar.xz
source tool/env.sh
flutter config --enable-linux-desktop
flutter precache --linux
```

`tool/env.sh` points `HOME`, `XDG_*` and `PUB_CACHE` into `.tooling/`, which keeps
the SDK, the pub cache and temporary files inside the project.

### 3. Build and run

```bash
make bootstrap      # flutter pub get
make test           # 64 unit and widget tests
make analyze        # static analysis, zero issues
make run            # debug build on this machine
make build          # release bundle in build/linux/x64/release/bundle
```

## Project layout

```
lib/
  main.dart              app bootstrap: prefs, settings, system accent
  app.dart               MaterialApp, themes, providers
  strings.dart           English strings (from upstream strings.xml)
  core/                  pure logic, no Flutter: roulette, presets, dice,
                         magic ball, recent sets
  state/                 settings controller, preference store, shortcut bus
  theme/                 accents and Material 3 theme builder
  services/              sound playback
  widgets/               result text, randomize button, blob background,
                         dice/coin/ball faces, recents and answers sheets
  screens/               shell, roulette, coin, dice, magic ball, settings,
                         about, intro
test/                    unit tests for the core rules, widget tests per screen
packaging/               desktop entry, AppStream data, icons, deb + flatpak
tool/                    env.sh, upstream asset fetcher
```

The rules that were ported from Kotlin are documented in `lib/core/` and pinned by
tests: the 30-option cap, duplicate handling, strict range validation, the recent
set algorithm with its pin sentinel and 10-set limit, the D6 pip rule, the 3 vs 3
sums, the magic ball answer pools and the two-answer custom threshold.

## Verified on this machine

- `flutter analyze` — no issues.
- `flutter test` — 64 tests passing.
- `flutter build linux --release` — bundle at `build/linux/x64/release/bundle`.
- The release binary launches against the system GTK 3 runtime (3.24.52) and
  writes its preferences; `dist/randomix_4.0.0-1_amd64.deb` is 8 MB, all
  `Depends` satisfiable on PikaOS 4 / Debian trixie (`apt-get -s install` clean).
- `flatpak run io.github.thenobody0817.Randomix` — installed as a user Flatpak from
  `org.freedesktop.Platform//25.08`, launches and persists state under
  `~/.var/app/io.github.thenobody0817.Randomix`.

## Differences from the Android app

- No vibration and no shake detection (no such hardware on a desktop).
- Android's animated vector drawables are re-authored as Flutter animations.
- The rating dialog is replaced by GitHub/F-Droid links; sharing is replaced by
  copying the result.
- The custom floating bottom bar becomes a standard Material 3 bottom bar or rail.
- English only for now; the upstream project has ~20 translations, and the string
  table is ready for them.
- The app id `io.github.thenobody0817.Randomix` is used for local builds; rename it to your own
  reverse-DNS identifier if you publish the port.

## Publishing

The scripts used to publish this repository are part of it:

```bash
tool/download-gh.sh                 # local GitHub CLI in .tooling/, no root
.tooling/gh/bin/gh auth login       # one-time browser login
make deb                            # builds dist/randomix_<version>-1_<arch>.deb
make publish                        # creates/updates the repo, tag and release
```

`publish.sh` installs a repository-local git credential helper that asks `gh`
for the token on demand, so no credential is stored in the repository or in
`~/.gitconfig`.

## License

MIT. The port and the reused upstream assets keep the original copyright notice;
see [LICENSE.upstream.md](LICENSE.upstream.md).
