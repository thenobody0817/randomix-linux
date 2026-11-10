# Randomix 4.0.0 for Linux

First desktop release of the Flutter port of [Randomix](https://github.com/m-i-n-a-r/randomix).

## Install

**Debian, Ubuntu, PikaOS and derivatives**

```bash
sudo apt install ./randomix_4.0.0-1_amd64.deb
```

Then start **Randomix** from the application grid, or run `randomix`.

**Flatpak (build from source)**

```bash
git clone https://github.com/thenobody0817/randomix-linux.git
cd randomix-linux
make flatpak
flatpak run io.github.thenobody0817.Randomix
```

## What's inside

- **Roulette** — custom options (up to 30, duplicate protection, optional removal
  of the chosen option), inclusive number ranges, A-Z / 1-100 / 52-card presets,
  and a recent-sets list you can restore, pin or delete.
- **Coin** — heads or tails, with a flip animation and streak messages.
- **Dice** — D4, D6, D8, D10, D12 and D20, one to ten dice, and the 3 vs 3 mode.
- **Magic Ball** — 30 answers, 6 optional rude answers, or your own list.
- Material 3 with light, dark and Amoled themes, twelve accent colours plus the
  system accent, animated blob background, sound effects, first-run introduction
  and settings.
- English UI. Keyboard: Space throws the active tool.

## Notes

- Package architecture: `amd64`. Rebuild with `make deb` on other machines.
- Sound needs GStreamer plugins (`gstreamer1.0-plugins-good`); without them the
  rest of the app is unaffected.
- Vibration and shake detection are Android-only and are not part of the port.

## Credits

Randomix was created by m.i.n.a.r. This port reuses the original MIT-licensed
assets and English texts; see `LICENSE.upstream.md` and `assets/NOTICE` in the
repository.
