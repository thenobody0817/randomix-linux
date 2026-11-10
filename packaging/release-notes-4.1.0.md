# Randomix 4.1.0 for Linux

Adds a choice of roulette spin animation, selectable in the app settings.

## What's new

- **Spin animation setting** under *Settings → Roulette*:
  - **Wheel** — a wheel turns until the winner is under the pointer, with the
    option currently passing the pointer read out in the centre. Stays readable
    up to 30 options because the labels are dropped past twelve and the hub
    carries the text.
  - **Cover flow** — cards slide past each other in perspective until the winner
    is in front.
  - **Chips** — the option chips light up in turn and stop on the winner; no new
    graphics, works with any number of options.
- The spin runs for 2.6–3.0 s and the result fades in afterwards. Input is locked
  while it plays.
- Range mode now counts through numbers instead of showing an empty gap, and the
  final number lands on the same value the fade reveals.

## Install

```bash
sudo apt install ./randomix_4.1.0-1_amd64.deb
```

or build the Flatpak from source with `make flatpak`.

## Credits

Randomix was created by m.i.n.a.r. This port reuses the original MIT-licensed
assets and English texts; see `LICENSE.upstream.md` and `assets/NOTICE`.
