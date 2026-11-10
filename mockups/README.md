# Roulette spin concepts (mock gallery)

A standalone HTML/JS gallery with 20 candidate animations for the roulette's
"spin" moment. No build step, no dependencies: open
[`roulette-gallery.html`](roulette-gallery.html) in any browser.

- **Spin** a single card, or **Spin all** to compare them side by side.
- **☆** stars a concept; the header keeps your shortlist (e.g. `1, 3, 14`).
- Keys: `S` spins all, `R` replays the starred cards.
- Every card uses the same eight sample options. The real app supports up to 30.

## The 20 concepts

| # | Concept | Flutter effort | Notes |
|---|---------|----------------|-------|
| 1 | Classic wheel | medium | Safest, most readable; labels get tight past ~12 options |
| 2 | Wheel with ticking clapper | hard | Tactile pointer tick; needs per-peg tangent animation |
| 3 | Wheel with roulette ball | hard | Closest to real roulette; two independent rotations |
| 4 | Motion-blur wheel | medium | Cheap to add (`ImageFiltered`/blur), sells the speed |
| 5 | Wheel with spring settle | medium | Small overshoot + spring back at the end |
| 6 | Wheel with centre readout | medium | The hub names the option currently under the pointer |
| 7 | Vertical slot reel | easy | Scales to 30 options; no geometry maths |
| 8 | Horizontal tape | easy | Scales to 30; reads like a measuring tape |
| 9 | 3D ring carousel | medium | `Transform` + perspective; compact, good for narrow windows |
| 10 | Cover flow | medium | Depth-sorted cards; playful with short labels |
| 11 | Shuffling card fan | medium | Feels like drawing a card; best for ≤10 options |
| 12 | Split-flap board | medium | Solari board tick; needs two-half flap for full fidelity |
| 13 | Scramble text | easy | Almost no new drawing code |
| 14 | Chip highlight race | easy | Uses the existing chips; no new graphics |
| 15 | Radar sweep | hard | Distinct silhouette; conic gradient needs a shader or sweep |
| 16 | Spiral vortex | medium | Dramatic; labels shrink as they converge |
| 17 | Octagon drum | hard | Vertical prism; many faces overlap, needs depth sorting |
| 18 | Bouncing ball | medium | Physics feel; ball path is a parabola per bounce |
| 19 | Pendulum pointer | medium | Slow and suspenseful; only needs `RotationTransition` |
| 20 | Shake + confetti reveal | easy | No long spin; celebratory and fast for repeats |

## Constraint to keep in mind

The app allows **up to 30 options**. A wheel is only legible to about 12 slices,
so a full implementation would either:

- use a wheel for ≤12 options and fall back to tape/slot/chips above that, or
- keep the wheel but move the labels out of the disc and show the winner big.

The reactive concepts (7, 8, 13, 14, 18) have no such limit.
