'use strict';

/* Randomix — roulette spin animation gallery.
 * 20 self-contained concepts, same 8 demo options, no dependencies.
 * The chosen concept will be re-implemented with Flutter animations. */

const OPTIONS = ['Pizza', 'Sushi', 'Tacos', 'Pasta', 'Burger', 'Salad', 'Curry', 'Ramen'];
const COLORS = ['#4c8dff', '#36c692', '#f2b134', '#ef6b6b', '#a97bff', '#3ec1d3', '#f78fb3', '#8bc34a'];
const N = OPTIONS.length;
const SEG = 360 / N;
const DPR = Math.min(window.devicePixelRatio || 1, 2);

const clamp = (v, a, b) => Math.min(b, Math.max(a, v));
const pick = () => Math.floor(Math.random() * N);
const mod360 = (v) => ((v % 360) + 360) % 360;
const modIndex = (v) => ((v % N) + N) % N;

const ease = {
  linear: (t) => t,
  outCubic: (t) => 1 - Math.pow(1 - t, 3),
  outQuart: (t) => 1 - Math.pow(1 - t, 4),
  outQuint: (t) => 1 - Math.pow(1 - t, 5),
  outBack: (t) => 1 + 1.7 * Math.pow(t - 1, 3) + 0.7 * Math.pow(t - 1, 2),
};

function animate(duration, frame, done, fn) {
  const t0 = performance.now();
  const ef = fn || ease.outCubic;
  const step = (now) => {
    const raw = clamp((now - t0) / duration, 0, 1);
    frame(ef(raw), raw);
    if (raw < 1) requestAnimationFrame(step);
    else if (done) done();
  };
  requestAnimationFrame(step);
}

/* ---------------------------------------------------------------- wheel */

function createWheel(size) {
  const canvas = document.createElement('canvas');
  canvas.width = size * DPR;
  canvas.height = size * DPR;
  canvas.style.width = size + 'px';
  canvas.style.height = size + 'px';
  const ctx = canvas.getContext('2d');
  ctx.scale(DPR, DPR);
  const cx = size / 2;
  const cy = size / 2;
  const R = size / 2 - 16;

  function draw(rotDeg, opts = {}) {
    ctx.clearRect(0, 0, size, size);

    ctx.beginPath();
    ctx.arc(cx, cy, R + 8, 0, Math.PI * 2);
    ctx.fillStyle = '#0a0e14';
    ctx.fill();
    ctx.strokeStyle = 'rgba(120,150,200,.28)';
    ctx.lineWidth = 2;
    ctx.stroke();

    for (let i = 0; i < N; i++) {
      const a0 = ((rotDeg + i * SEG - 90) * Math.PI) / 180;
      const a1 = ((rotDeg + (i + 1) * SEG - 90) * Math.PI) / 180;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.arc(cx, cy, R, a0, a1);
      ctx.closePath();
      ctx.fillStyle = COLORS[i];
      ctx.fill();
      if (opts.highlight === i) {
        ctx.fillStyle = 'rgba(255,255,255,.32)';
        ctx.fill();
      }
      ctx.strokeStyle = 'rgba(10,14,20,.35)';
      ctx.lineWidth = 1;
      ctx.stroke();

      const mid = ((rotDeg + i * SEG + SEG / 2 - 90) * Math.PI) / 180;
      ctx.save();
      ctx.translate(cx, cy);
      ctx.rotate(mid);
      ctx.textAlign = 'right';
      ctx.textBaseline = 'middle';
      ctx.font = '600 11px Inter, system-ui, sans-serif';
      ctx.fillStyle = 'rgba(8,12,18,.88)';
      ctx.fillText(OPTIONS[i], R - 14, 0);
      ctx.restore();
    }

    ctx.beginPath();
    ctx.arc(cx, cy, 30, 0, Math.PI * 2);
    ctx.fillStyle = '#0d131c';
    ctx.fill();
    ctx.strokeStyle = 'rgba(120,150,200,.32)';
    ctx.lineWidth = 2;
    ctx.stroke();

    if (opts.clapper !== undefined) {
      ctx.save();
      ctx.translate(cx, cy - R - 12);
      ctx.rotate((opts.clapper * Math.PI) / 180);
      ctx.beginPath();
      ctx.moveTo(-9, -6);
      ctx.lineTo(9, -6);
      ctx.lineTo(0, 22);
      ctx.closePath();
      ctx.fillStyle = '#f2f5fa';
      ctx.fill();
      ctx.strokeStyle = '#0a0e14';
      ctx.lineWidth = 1.5;
      ctx.stroke();
      ctx.restore();
    } else {
      ctx.beginPath();
      ctx.moveTo(cx - 9, cy - R - 14);
      ctx.lineTo(cx + 9, cy - R - 14);
      ctx.lineTo(cx, cy - R + 10);
      ctx.closePath();
      ctx.fillStyle = '#f2f5fa';
      ctx.fill();
      ctx.strokeStyle = '#0a0e14';
      ctx.lineWidth = 1.5;
      ctx.stroke();
    }

    if (opts.ball) {
      const a = ((opts.ball.angle - 90) * Math.PI) / 180;
      const bx = cx + Math.cos(a) * opts.ball.radius;
      const by = cy + Math.sin(a) * opts.ball.radius;
      ctx.beginPath();
      ctx.arc(bx, by, 6, 0, Math.PI * 2);
      ctx.fillStyle = '#ffffff';
      ctx.fill();
      ctx.strokeStyle = 'rgba(10,14,20,.45)';
      ctx.lineWidth = 1;
      ctx.stroke();
    }

    if (opts.highlight !== undefined) {
      const a0 = ((rotDeg + opts.highlight * SEG - 90) * Math.PI) / 180;
      const a1 = ((rotDeg + (opts.highlight + 1) * SEG - 90) * Math.PI) / 180;
      ctx.beginPath();
      ctx.moveTo(cx, cy);
      ctx.arc(cx, cy, R, a0, a1);
      ctx.closePath();
      ctx.strokeStyle = 'rgba(255,255,255,.92)';
      ctx.lineWidth = 3;
      ctx.stroke();
    }
  }

  draw(0);
  return { canvas, draw };
}

/* ------------------------------------------------------- 1. classic */

function demoClassic() {
  return {
    num: 1,
    title: 'Classic wheel',
    effort: 'medium',
    desc: 'A segmented wheel easing out under a fixed pointer. Every option is visible at once; the safest default.',
    build(stage) {
      const wheel = createWheel(232);
      stage.append(wheel.canvas);
      let rot = 0;
      wheel.draw(rot);
      return {
        async spin() {
          const winner = pick();
          const start = rot;
          const delta = 360 * 5 + mod360(-(winner * SEG + SEG / 2) - start);
          await new Promise((r) => animate(3600, (e) => {
            rot = start + delta * e;
            wheel.draw(rot);
          }, r));
          wheel.draw(rot, { highlight: winner });
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 2. clapper */

function demoClapper() {
  return {
    num: 2,
    title: 'Wheel with ticking clapper',
    effort: 'hard',
    desc: 'The pointer flicks over every peg as it passes, slowing down with the wheel. Very tactile, like a casino wheel.',
    build(stage) {
      const wheel = createWheel(232);
      stage.append(wheel.canvas);
      let rot = 0;
      wheel.draw(rot, { clapper: 0 });
      return {
        async spin() {
          const winner = pick();
          const start = rot;
          const delta = 360 * 5 + mod360(-(winner * SEG + SEG / 2) - start);
          let prev = start;
          await new Promise((r) => animate(3600, (e) => {
            rot = start + delta * e;
            const speed = Math.abs(rot - prev);
            prev = rot;
            const tick = Math.sin((rot / SEG) * Math.PI);
            const angle = clamp(speed * 0.95, 0, 13) * tick;
            wheel.draw(rot, { clapper: angle });
          }, r));
          wheel.draw(rot, { clapper: 0, highlight: winner });
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 3. ball */

function demoBall() {
  return {
    num: 3,
    title: 'Wheel with roulette ball',
    effort: 'hard',
    desc: 'The wheel turns one way while a ball orbits the other and drops into the winning pocket. Closest to real roulette.',
    build(stage) {
      const wheel = createWheel(200);
      stage.append(wheel.canvas);
      let rot = 0;
      let ball = { angle: -720, radius: 96 };
      wheel.draw(rot, { ball });
      return {
        async spin() {
          const winner = pick();
          const start = rot;
          const delta = 360 * 4 + mod360(-(winner * SEG + SEG / 2) - start);
          await new Promise((r) => animate(4200, (e) => {
            rot = start + delta * e;
            ball = { angle: -720 * (1 - e), radius: 96 - 32 * e };
            wheel.draw(rot, { ball });
          }, r));
          wheel.draw(rot, { ball: { angle: 0, radius: 64 }, highlight: winner });
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 4. blur */

function demoBlur() {
  return {
    num: 4,
    title: 'Motion-blur wheel',
    effort: 'medium',
    desc: 'Same wheel, but the disc blurs while it is fast and sharpens as it stops. Cheap to add, makes speed readable.',
    build(stage) {
      const wheel = createWheel(232);
      stage.append(wheel.canvas);
      let rot = 0;
      wheel.draw(rot);
      return {
        async spin() {
          const winner = pick();
          const start = rot;
          const delta = 360 * 5 + mod360(-(winner * SEG + SEG / 2) - start);
          let prev = start;
          await new Promise((r) => animate(3600, (e) => {
            rot = start + delta * e;
            const speed = Math.abs(rot - prev);
            prev = rot;
            wheel.canvas.style.filter = 'blur(' + clamp(speed * 0.6, 0, 7).toFixed(2) + 'px)';
            wheel.draw(rot);
          }, r));
          wheel.canvas.style.filter = '';
          wheel.draw(rot, { highlight: winner });
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 5. spring */

function demoSpring() {
  return {
    num: 5,
    title: 'Wheel with a spring settle',
    effort: 'medium',
    desc: 'The wheel overshoots the pocket slightly, then springs back. Adds a small physical beat at the end.',
    build(stage) {
      const wheel = createWheel(232);
      stage.append(wheel.canvas);
      let rot = 0;
      wheel.draw(rot);
      return {
        async spin() {
          const winner = pick();
          const start = rot;
          const delta = 360 * 5 + mod360(-(winner * SEG + SEG / 2) - start);
          await new Promise((r) => animate(3000, (e) => {
            rot = start + (delta + 7) * e;
            wheel.draw(rot);
          }, r));
          await new Promise((r) => animate(900, (e, t) => {
            rot = start + delta + 7 - 7 * e + Math.sin(t * Math.PI * 2) * 2.2 * (1 - t);
            wheel.draw(rot);
          }, r));
          wheel.draw(rot, { highlight: winner });
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 6. ticker */

function demoTicker() {
  return {
    num: 6,
    title: 'Wheel with centre readout',
    effort: 'medium',
    desc: 'The wheel spins while the hub flashes the option currently under the pointer, so the result is readable mid-spin.',
    build(stage) {
      const wrap = document.createElement('div');
      wrap.className = 'wheel-wrap';
      const wheel = createWheel(232);
      const ticker = document.createElement('div');
      ticker.className = 'ticker';
      ticker.textContent = '—';
      wrap.append(wheel.canvas, ticker);
      stage.append(wrap);
      let rot = 0;
      wheel.draw(rot);
      return {
        async spin() {
          const winner = pick();
          const start = rot;
          const delta = 360 * 5 + mod360(-(winner * SEG + SEG / 2) - start);
          await new Promise((r) => animate(3600, (e) => {
            rot = start + delta * e;
            ticker.textContent = OPTIONS[Math.floor(mod360(rot) / SEG) % N];
            wheel.draw(rot);
          }, r));
          wheel.draw(rot, { highlight: winner });
          ticker.textContent = OPTIONS[winner];
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 7. slot */

function demoSlot() {
  return {
    num: 7,
    title: 'Vertical slot reel',
    effort: 'easy',
    desc: 'One column of options scrolls like a slot machine behind a highlighted band. Cheap to build and very legible.',
    build(stage) {
      const H = 54;
      const REPS = 14;
      const win = document.createElement('div');
      win.className = 'slot-window';
      const strip = document.createElement('div');
      strip.className = 'slot-strip';
      for (let r = 0; r < REPS; r++) {
        for (let i = 0; i < N; i++) {
          const d = document.createElement('div');
          d.className = 'slot-item';
          d.textContent = OPTIONS[i];
          d.style.color = COLORS[i];
          strip.append(d);
        }
      }
      const band = document.createElement('div');
      band.className = 'slot-band';
      win.append(strip, band);
      stage.append(win);
      let offset = H * N;
      const apply = () => { strip.style.transform = 'translateY(' + -offset + 'px)'; };
      apply();
      return {
        async spin() {
          const winner = pick();
          const targetIndex = (REPS - 3) * N + winner;
          const target = (targetIndex - 1) * H;
          const start = offset;
          await new Promise((r) => animate(3400, (e) => {
            offset = start + (target - start) * e;
            apply();
          }, r, ease.outQuart));
          offset = target;
          apply();
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 8. tape */

function demoTape() {
  return {
    num: 8,
    title: 'Horizontal tape',
    effort: 'easy',
    desc: 'All options slide past a centre marker like a measuring tape, decelerating onto the winner. Reads left to right.',
    build(stage) {
      const W = 96;
      const REPS = 12;
      const win = document.createElement('div');
      win.className = 'tape-window';
      const strip = document.createElement('div');
      strip.className = 'tape-strip';
      for (let r = 0; r < REPS; r++) {
        for (let i = 0; i < N; i++) {
          const d = document.createElement('div');
          d.className = 'tape-item';
          d.textContent = OPTIONS[i];
          d.style.color = COLORS[i];
          strip.append(d);
        }
      }
      const marker = document.createElement('div');
      marker.className = 'tape-marker';
      win.append(strip, marker);
      stage.append(win);
      let offset = 0;
      const apply = () => { strip.style.transform = 'translateX(' + offset + 'px)'; };
      apply();
      return {
        async spin() {
          const winner = pick();
          const rect = win.getBoundingClientRect();
          const targetIndex = (REPS - 3) * N + winner;
          const target = -(targetIndex * W + W / 2 - rect.width / 2);
          const start = offset;
          await new Promise((r) => animate(3400, (e) => {
            offset = start + (target - start) * e;
            apply();
          }, r, ease.outQuart));
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 9. ring */

function demoRing() {
  return {
    num: 9,
    title: '3D ring carousel',
    effort: 'medium',
    desc: 'Options sit on a rotating ring; the front one is the result. Modern and compact, fits narrow windows.',
    build(stage) {
      const scene = document.createElement('div');
      scene.className = 'scene';
      const ring = document.createElement('div');
      ring.className = 'ring';
      const R = 96;
      OPTIONS.forEach((o, i) => {
        const it = document.createElement('div');
        it.className = 'ring-item';
        it.textContent = o;
        it.style.background = COLORS[i];
        it.style.transform = 'rotateY(' + i * SEG + 'deg) translateZ(' + R + 'px)';
        ring.append(it);
      });
      scene.append(ring);
      stage.append(scene);
      let pos = 0;
      return {
        async spin() {
          const winner = pick();
          const start = pos;
          const target = start + 360 * 3 + mod360(winner * SEG - start);
          await new Promise((r) => animate(3600, (e) => {
            pos = start + (target - start) * e;
            ring.style.transform = 'rotateY(' + -pos + 'deg)';
          }, r));
          pos = target;
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 10. coverflow */

function demoCover() {
  return {
    num: 10,
    title: 'Cover flow',
    effort: 'medium',
    desc: 'Cards slide past each other with perspective and depth until the winner sits in front. Playful, good with short labels.',
    build(stage) {
      const cover = document.createElement('div');
      cover.className = 'cover';
      const items = OPTIONS.map((o, i) => {
        const d = document.createElement('div');
        d.className = 'cover-item';
        d.textContent = o;
        d.style.background = COLORS[i];
        cover.append(d);
        return d;
      });
      stage.append(cover);
      let pos = 0;
      const apply = () => {
        items.forEach((el, i) => {
          let r = modIndex(i - pos);
          if (r > N / 2) r -= N;
          const a = Math.abs(r);
          el.style.transform =
            'translateX(' + r * 78 + 'px) translateZ(' + -a * 80 + 'px) rotateY(' + -r * 26 + 'deg) scale(' + (1 - a * 0.07) + ')';
          el.style.opacity = String(clamp(1 - a * 0.16, 0.12, 1));
          el.style.zIndex = String(100 - Math.round(a * 10));
        });
      };
      apply();
      return {
        async spin() {
          const winner = pick();
          const start = pos;
          const target = start + N * 2 + modIndex(winner - start);
          await new Promise((r) => animate(3400, (e) => {
            pos = start + (target - start) * e;
            apply();
          }, r));
          pos = target;
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 11. fan */

function demoFan() {
  return {
    num: 11,
    title: 'Shuffling card fan',
    effort: 'medium',
    desc: 'A fan of cards wobbles, then the winner lifts out to the middle. Feels like drawing a card rather than spinning.',
    build(stage) {
      const fan = document.createElement('div');
      fan.className = 'fan';
      const cards = OPTIONS.map((o, i) => {
        const d = document.createElement('div');
        d.className = 'fan-card';
        d.textContent = o;
        d.style.background = COLORS[i];
        fan.append(d);
        return d;
      });
      stage.append(fan);
      const layout = (spread, lift) => {
        cards.forEach((c, i) => {
          const t = (i - (N - 1) / 2) / ((N - 1) / 2);
          c.style.transform = 'rotate(' + t * spread + 'deg) translateY(' + Math.abs(t) * lift + 'px)';
        });
      };
      layout(44, 0);
      return {
        async spin() {
          const winner = pick();
          cards.forEach((c) => c.classList.remove('winner', 'dim'));
          layout(44, 0);
          await new Promise((r) => animate(1100, (e, t) => {
            const wobble = Math.sin(t * Math.PI * 6) * (1 - t) * 11;
            layout(44 + wobble, 10);
          }, r, ease.linear));
          layout(52, 14);
          await new Promise((r) => setTimeout(r, 120));
          cards.forEach((c, i) => c.classList.toggle('dim', i !== winner));
          cards[winner].classList.add('winner');
          await new Promise((r) => setTimeout(r, 680));
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 12. split flap */

function demoFlap() {
  return {
    num: 12,
    title: 'Split-flap board',
    effort: 'medium',
    desc: 'A Solari-style flap flips through options with a mechanical tick and slows onto the winner. Great for short option names.',
    build(stage) {
      const box = document.createElement('div');
      box.className = 'flap-stage';
      const face = document.createElement('div');
      face.className = 'flap-face';
      face.style.background = COLORS[0];
      face.textContent = OPTIONS[0];
      const line = document.createElement('div');
      line.className = 'flap-line';
      box.append(face, line);
      stage.append(box);
      let current = 0;
      async function flipTo(index, duration) {
        await new Promise((r) => animate(duration, (e) => {
          face.style.transform = 'rotateX(' + -e * 180 + 'deg)';
          if (e >= 0.5) {
            face.textContent = OPTIONS[index];
            face.style.background = COLORS[index];
          }
        }, r, ease.linear));
        face.style.transform = 'rotateX(0deg)';
        current = index;
      }
      return {
        async spin() {
          const winner = pick();
          let dur = 70;
          for (let k = 0; k < 11; k++) {
            const idx = (current + 1 + Math.floor(Math.random() * (N - 1))) % N;
            await flipTo(idx, dur);
            dur *= 1.17;
          }
          await flipTo(winner, Math.max(240, dur));
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 13. scramble */

function demoScramble() {
  return {
    num: 13,
    title: 'Scramble text',
    effort: 'easy',
    desc: 'The option name flickers through random values, decelerating to the winner. Smallest amount of new drawing code.',
    build(stage) {
      const el = document.createElement('div');
      el.className = 'scramble';
      el.textContent = OPTIONS[0];
      stage.append(el);
      return {
        async spin() {
          const winner = pick();
          let delay = 35;
          let elapsed = 0;
          while (elapsed < 2300) {
            el.textContent = OPTIONS[pick()];
            await new Promise((r) => setTimeout(r, delay));
            elapsed += delay;
            delay *= 1.075;
          }
          el.textContent = OPTIONS[winner];
          el.style.color = COLORS[winner];
          el.classList.add('pop');
          setTimeout(() => el.classList.remove('pop'), 280);
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 14. chip race */

function demoChips() {
  return {
    num: 14,
    title: 'Chip highlight race',
    effort: 'easy',
    desc: 'The existing option chips light up one after another, slowing down on the winner. No new graphics at all.',
    build(stage) {
      const wrap = document.createElement('div');
      wrap.className = 'chips';
      const chips = OPTIONS.map((o, i) => {
        const d = document.createElement('div');
        d.className = 'chip';
        d.textContent = o;
        d.style.borderColor = COLORS[i] + '55';
        wrap.append(d);
        return d;
      });
      stage.append(wrap);
      let lit = -1;
      const setLit = (i) => {
        if (lit >= 0) {
          chips[lit].classList.remove('on');
          chips[lit].style.background = '';
        }
        lit = i;
        chips[i].classList.add('on');
        chips[i].style.background = COLORS[i];
      };
      return {
        async spin() {
          chips.forEach((c) => {
            c.classList.remove('win', 'on');
            c.style.background = '';
          });
          lit = -1;
          const winner = pick();
          const total = N * 4 + winner;
          await new Promise((r) => animate(3200, (e) => {
            const idx = Math.floor(e * total) % N;
            if (idx !== lit) setLit(idx);
          }, r, ease.outCubic));
          setLit(winner);
          chips[winner].classList.add('win');
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 15. radar */

function demoRadar() {
  return {
    num: 15,
    title: 'Radar sweep',
    effort: 'hard',
    desc: 'A rotating beam sweeps over a circular arrangement of labels and locks onto the winner. Very different silhouette.',
    build(stage) {
      const radar = document.createElement('div');
      radar.className = 'radar';
      const ring = document.createElement('div');
      ring.className = 'radar-ring';
      const beam = document.createElement('div');
      beam.className = 'beam';
      const cx = 120;
      const cy = 120;
      const R = 84;
      const labels = OPTIONS.map((o, i) => {
        const a = ((i * SEG - 90) * Math.PI) / 180;
        const d = document.createElement('div');
        d.className = 'radar-label';
        d.textContent = o;
        d.style.left = cx + Math.cos(a) * R + 'px';
        d.style.top = cy + Math.sin(a) * R + 'px';
        radar.append(d);
        return d;
      });
      radar.append(ring, beam);
      stage.append(radar);
      return {
        async spin() {
          const winner = pick();
          labels.forEach((l) => l.classList.remove('win'));
          const target = 360 * 3 + winner * SEG;
          await new Promise((r) => animate(3600, (e) => {
            beam.style.transform = 'rotate(' + target * e + 'deg)';
          }, r));
          labels[winner].classList.add('win');
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 16. spiral */

function demoSpiral() {
  return {
    num: 16,
    title: 'Spiral vortex',
    effort: 'medium',
    desc: 'Options spiral inward while rotating, then the winner resolves in the centre. Dramatic, best with few options.',
    build(stage) {
      const wrap = document.createElement('div');
      wrap.className = 'spiral';
      const res = document.createElement('div');
      res.className = 'vortex-result';
      const labels = OPTIONS.map((o, i) => {
        const d = document.createElement('div');
        d.className = 'spiral-label';
        d.textContent = o;
        d.style.color = COLORS[i];
        wrap.append(d);
        return d;
      });
      wrap.append(res);
      stage.append(wrap);
      const position = (t) => {
        labels.forEach((el, i) => {
          const angle = ((i * SEG + t * 720 - 90) * Math.PI) / 180;
          const radius = 98 * (1 - 0.7 * t);
          el.style.transform =
            'translate(' + Math.cos(angle) * radius + 'px,' + Math.sin(angle) * radius + 'px) scale(' + (1 - 0.5 * t) + ')';
          el.style.opacity = String(1 - 0.8 * t);
        });
      };
      position(0);
      return {
        async spin() {
          const winner = pick();
          res.classList.remove('show');
          res.textContent = '';
          labels.forEach((l) => { l.style.opacity = '1'; });
          position(0);
          await new Promise((r) => animate(3600, (e) => position(e), r, ease.outCubic));
          labels.forEach((l) => { l.style.opacity = '0'; });
          res.textContent = OPTIONS[winner];
          res.style.color = COLORS[winner];
          res.classList.add('show');
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 17. drum */

function demoDrum() {
  return {
    num: 17,
    title: 'Octagon drum',
    effort: 'hard',
    desc: 'Eight faces on a vertical prism roll like a drum until the winner faces you. A vertical take on the ring carousel.',
    build(stage) {
      const scene = document.createElement('div');
      scene.className = 'scene';
      const drum = document.createElement('div');
      drum.className = 'drum';
      const R = 92;
      OPTIONS.forEach((o, i) => {
        const it = document.createElement('div');
        it.className = 'drum-item';
        it.textContent = o;
        it.style.background = COLORS[i];
        it.style.transform = 'rotateX(' + -i * SEG + 'deg) translateZ(' + R + 'px)';
        drum.append(it);
      });
      scene.append(drum);
      stage.append(scene);
      const faces = [...drum.children];
      let pos = 0;
      const apply = () => {
        drum.style.transform = 'rotateX(' + pos + 'deg)';
        faces.forEach((f, i) => {
          const a = ((pos - i * SEG) * Math.PI) / 180;
          f.style.opacity = String(0.16 + 0.84 * Math.max(0, Math.cos(a)));
        });
      };
      apply();
      return {
        async spin() {
          const winner = pick();
          const start = pos;
          const target = start + 360 * 3 + mod360(winner * SEG - start);
          await new Promise((r) => animate(3600, (e) => {
            pos = start + (target - start) * e;
            apply();
          }, r));
          pos = target;
          apply();
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 18. bounce */

function demoBounce() {
  return {
    num: 18,
    title: 'Bouncing ball',
    effort: 'medium',
    desc: 'A ball bounces down the row of tiles, each bounce highlighting one, until it settles on the winner.',
    build(stage) {
      const row = document.createElement('div');
      row.className = 'bounce-row';
      const tiles = OPTIONS.map((o, i) => {
        const d = document.createElement('div');
        d.className = 'bounce-tile';
        d.textContent = o;
        d.style.background = COLORS[i];
        row.append(d);
        return d;
      });
      const ball = document.createElement('div');
      ball.className = 'ball';
      stage.append(row, ball);
      return {
        async spin() {
          tiles.forEach((t) => t.classList.remove('win'));
          const winner = pick();
          const steps = N * 2 + winner;
          const rowRect = row.getBoundingClientRect();
          const stageRect = stage.getBoundingClientRect();
          const tileW = rowRect.width / N;
          const baseY = rowRect.top - stageRect.top - 26;
          let lastTile = -1;
          await new Promise((r) => animate(3200, (e) => {
            const p = e * steps;
            const i = Math.min(steps - 1, Math.floor(p));
            const frac = p - i;
            const x = (modIndex(i) + 0.5) * tileW;
            const height = Math.sin(frac * Math.PI) * 74 * (1 - e * 0.3);
            ball.style.transform = 'translate(' + (x - 12) + 'px,' + (baseY - height) + 'px)';
            if (i !== lastTile) {
              lastTile = i;
              const t = tiles[modIndex(i)];
              t.style.filter = 'brightness(1.4)';
              setTimeout(() => { t.style.filter = ''; }, 110);
            }
          }, r, ease.outCubic));
          const wx = (winner + 0.5) * tileW;
          ball.style.transform = 'translate(' + (wx - 12) + 'px,' + baseY + 'px)';
          tiles[winner].classList.add('win');
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 19. pendulum */

function demoPendulum() {
  return {
    num: 19,
    title: 'Pendulum pointer',
    effort: 'medium',
    desc: 'A weighted pointer swings over the row and dies down on the winner. Slower, more suspenseful than a wheel.',
    build(stage) {
      const wrap = document.createElement('div');
      wrap.className = 'pendulum';
      const arm = document.createElement('div');
      arm.className = 'pendulum-arm';
      const bob = document.createElement('div');
      bob.className = 'pendulum-bob';
      arm.append(bob);
      const row = document.createElement('div');
      row.className = 'pend-row';
      const items = OPTIONS.map((o, i) => {
        const d = document.createElement('div');
        d.className = 'pend-item';
        d.textContent = o;
        d.style.background = COLORS[i];
        row.append(d);
        return d;
      });
      wrap.append(arm, row);
      stage.append(wrap);
      let angle = 0;
      const apply = () => { arm.style.transform = 'rotate(' + angle + 'deg)'; };
      apply();
      const aim = (winner) => {
        const wrapRect = wrap.getBoundingClientRect();
        const tile = items[winner].getBoundingClientRect();
        const dx = tile.left + tile.width / 2 - (wrapRect.left + wrapRect.width / 2);
        const armLength = 112;
        return (Math.atan2(dx, armLength) * 180) / Math.PI;
      };
      return {
        async spin() {
          items.forEach((i) => i.classList.remove('win'));
          const winner = pick();
          const target = aim(winner);
          await new Promise((r) => animate(3200, (e, t) => {
            const settle = 1 - (1 - t) * (1 - t);
            angle = target * settle + Math.sin(t * Math.PI * 4.5) * Math.pow(1 - t, 2) * 34;
            apply();
          }, r, ease.linear));
          angle = target;
          apply();
          items[winner].classList.add('win');
          return winner;
        },
      };
    },
  };
}

/* ------------------------------------------------------- 20. confetti */

function demoConfetti() {
  return {
    num: 20,
    title: 'Shake and confetti reveal',
    effort: 'easy',
    desc: 'A short shake, then the winner pops with confetti. No long spin: instant but celebratory, good for fast repeats.',
    build(stage) {
      const wrap = document.createElement('div');
      wrap.className = 'confetti-wrap';
      const card = document.createElement('div');
      card.className = 'confetti-card';
      card.textContent = '?';
      const canvas = document.createElement('canvas');
      canvas.className = 'confetti-canvas';
      wrap.append(card, canvas);
      stage.append(wrap);

      function sizeCanvas() {
        const r = wrap.getBoundingClientRect();
        canvas.width = r.width * DPR;
        canvas.height = r.height * DPR;
        canvas.style.width = r.width + 'px';
        canvas.style.height = r.height + 'px';
      }

      async function confetti(color) {
        sizeCanvas();
        const ctx = canvas.getContext('2d');
        ctx.setTransform(DPR, 0, 0, DPR, 0, 0);
        const W = canvas.width / DPR;
        const H = canvas.height / DPR;
        const parts = Array.from({ length: 130 }, () => ({
          x: W / 2,
          y: H / 2,
          vx: (Math.random() - 0.5) * 10,
          vy: (Math.random() - 0.95) * 10,
          g: 0.24,
          c: Math.random() < 0.5 ? color : COLORS[Math.floor(Math.random() * N)],
          s: 2 + Math.random() * 4,
          life: 1,
        }));
        await new Promise((r) => animate(1400, () => {
          ctx.clearRect(0, 0, W, H);
          parts.forEach((p) => {
            p.vy += p.g;
            p.x += p.vx;
            p.y += p.vy;
            p.life -= 0.012;
            ctx.globalAlpha = Math.max(0, p.life);
            ctx.fillStyle = p.c;
            ctx.beginPath();
            ctx.arc(p.x, p.y, p.s, 0, Math.PI * 2);
            ctx.fill();
          });
          ctx.globalAlpha = 1;
        }, r, ease.linear));
        ctx.clearRect(0, 0, W, H);
      }

      return {
        async spin() {
          const winner = pick();
          card.classList.remove('win');
          card.classList.add('shake');
          card.textContent = '…';
          card.style.background = '#233049';
          await new Promise((r) => setTimeout(r, 700));
          card.classList.remove('shake');
          card.classList.add('win');
          card.textContent = OPTIONS[winner];
          card.style.background = COLORS[winner];
          await confetti(COLORS[winner]);
          return winner;
        },
      };
    },
  };
}

/* ---------------------------------------------------------------- ui */

const DEMOS = [
  demoClassic(), demoClapper(), demoBall(), demoBlur(), demoSpring(),
  demoTicker(), demoSlot(), demoTape(), demoRing(), demoCover(),
  demoFan(), demoFlap(), demoScramble(), demoChips(), demoRadar(),
  demoSpiral(), demoDrum(), demoBounce(), demoPendulum(), demoConfetti(),
];

const grid = document.getElementById('grid');
const shortlistEl = document.getElementById('shortlist');
const picked = new Set();
const controllers = [];

function updateShortlist() {
  const nums = [...picked].sort((a, b) => a - b);
  shortlistEl.innerHTML = nums.length ? 'Shortlist: <b>' + nums.join(', ') + '</b>' : 'Shortlist: —';
}

function render() {
  DEMOS.forEach((demo) => {
    const card = document.createElement('article');
    card.className = 'card';
    card.dataset.num = demo.num;
    card.innerHTML =
      '<header>' +
        '<div class="num">' + demo.num + '</div>' +
        '<div>' +
          '<h2>' + demo.title + '</h2>' +
          '<p class="desc">' + demo.desc + '</p>' +
          '<div class="meta"><span class="tag ' + demo.effort + '">' + demo.effort + ' in Flutter</span><span class="tag">8 options</span></div>' +
        '</div>' +
        '<button class="star" title="Add to shortlist">☆</button>' +
      '</header>' +
      '<div class="stage"></div>' +
      '<footer><span class="result">Ready</span><button class="btn spin primary">Spin</button></footer>';

    grid.append(card);
    const stage = card.querySelector('.stage');
    const resultEl = card.querySelector('.result');
    const spinBtn = card.querySelector('.spin');
    const star = card.querySelector('.star');
    const ctrl = demo.build(stage);
    let busy = false;

    async function run() {
      if (busy) return;
      busy = true;
      spinBtn.disabled = true;
      resultEl.textContent = 'Spinning…';
      try {
        const w = await ctrl.spin();
        resultEl.innerHTML = '<span class="dot" style="background:' + COLORS[w] + '"></span>Winner: <b>' + OPTIONS[w] + '</b>';
      } finally {
        busy = false;
        spinBtn.disabled = false;
      }
    }

    spinBtn.addEventListener('click', run);
    star.addEventListener('click', () => {
      if (picked.has(demo.num)) {
        picked.delete(demo.num);
        card.classList.remove('picked');
        star.textContent = '☆';
      } else {
        picked.add(demo.num);
        card.classList.add('picked');
        star.textContent = '★';
      }
      updateShortlist();
    });

    controllers.push({ demo, run, card });
  });
  updateShortlist();
}

document.getElementById('spin-all').addEventListener('click', () => {
  controllers.forEach((c, i) => setTimeout(() => c.run(), i * 150));
});

document.getElementById('clear').addEventListener('click', () => {
  picked.clear();
  document.querySelectorAll('.card').forEach((c) => c.classList.remove('picked'));
  document.querySelectorAll('.star').forEach((s) => { s.textContent = '☆'; });
  updateShortlist();
});

document.addEventListener('keydown', (e) => {
  if (e.key === 's' || e.key === 'S') document.getElementById('spin-all').click();
  if (e.key === 'r' || e.key === 'R') {
    controllers.filter((c) => picked.has(c.demo.num)).forEach((c, i) => setTimeout(c.run, i * 150));
  }
});

render();

// Convenience for automated checks: file:///...?autospin spins every card once.
if (location.search.indexOf('autospin') !== -1) {
  setTimeout(() => document.getElementById('spin-all').click(), 200);
}
