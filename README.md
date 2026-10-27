# Garlic Panic! - My WarioWare-Style Kitchen Microgame Rush

**Play Live in the Browser:** [https://aariv.me/garlic-panic/](https://aariv.me/garlic-panic/)

![Title screen](screenshot1.png)

![DODGE! in action](screenshot2.png)

I built **Garlic Panic!** for the Hack Club Stardance **"Make a WarioWare Game"** and **"Make a WarioWare Game 2"** missions. It is a fast-paced arcade game built with **Godot 4.7** (GDScript) alongside a full **HTML5 Canvas + Web Audio** web port so anyone can play all five microgames right in the browser without installing Godot.

---

## Why I Made Garlic Panic!

When I started the Stardance WarioWare mission, I wanted to make something that actually captures the panic of classic *WarioWare, Inc.: Mega Microgame$!* where the game barely gives you a single word (`DODGE!`, `MASH!`, `CATCH!`, `TIMING!`, `SLICE!`) before the timer starts ticking down.

Because Wario's signature food is garlic, I flipped the perspective: **you play as a five-clove garlic bulb trying to survive a chaotic kitchen** for 12 escalating rounds. Every time you clear a microgame, the global speed multiplier ramps up by `+0.15x` (from `1.00x` all the way to `2.50x`). A game about time pressure feels way more fun when the entire clock and physics engine are speeding up underneath you.

---

## All 5 Microgames & How They Work

I designed five distinct microgames so that each round forces your hands and brain to switch between completely different mechanics:

| # | Microgame | Godot Scene & Script | Controls | How It Works & Win Condition |
|---|-----------|----------------------|----------|------------------------------|
| 1 | **DODGE!** | `scenes/minigame_1.tscn`<br>`scripts/minigame_1.gd` | `Left` / `Right` Arrows, `A` / `D`, or Mouse | Crimson spikes rain down from the top of the screen at `(170..260) * speed_multiplier` px/s. Move your garlic clove across the floor and survive until the countdown reaches `0.0s`. |
| 2 | **MASH!** | `scenes/minigame_2.tscn`<br>`scripts/minigame_2.gd` | `SPACE` or Rapid Left Click | Mash `SPACE` or click the giant central garlic bulb to hit the target quota (`ceil(10 * speed_multiplier)`) before time runs out. Each press triggers a springy squash-and-stretch animation (`0.86x` scale bounce) and a rising triangle-wave synth pop. |
| 3 | **CATCH!** | `scenes/minigame_3.tscn`<br>`scripts/minigame_3.gd` | `Left` / `Right` Arrows, `A` / `D`, or Mouse | Slide the golden kitchen paddle horizontally at `320 px/s` to catch a falling star dropping at `200 * speed_multiplier` px/s before it hits the floor. |
| 4 | **TIMING!** | `scenes/minigame_4.tscn`<br>`scripts/minigame_4.gd` | `SPACE` or Click `LOCK IN!` | A high-speed marker oscillates left and right across a meter (`380 * speed_multiplier` px/s). Press `SPACE` or click when the cursor is inside the central green target zone (`x = 270..370`). Missing the green zone costs a garlic life immediately. |
| 5 | **SLICE!** | `scenes/minigame_5.tscn`<br>`scripts/minigame_5.gd` | `SPACE` or Click `CHOP!` | On a wooden cutting board, a red tomato target and a friendly garlic bulb slide back and forth through a central green chop zone under a chef's cleaver. Press `SPACE` or click `CHOP!` to slice the tomato while the garlic is safely out of the way! |

---

## Features I Built Into the Game

- **5-Clove Life System & Intermission Screen (`scenes/timer_screen.tscn`)**: Between every microgame, you land in a 2.2-second intermission room showing your remaining garlic lives, current round (`Level 1 / 12`), score, active win streak, speed multiplier, and a preview of which microgame is coming up next.
- **Global Speed Ramp (`scripts/global.gd`)**: Every microgame win increases `Global.speed_multiplier` by `+0.15x` (capped at `2.5x`). That single multiplier scales spike fall velocity, spawn frequency, button-mash quotas, star drop speed, timing bar oscillation speed, cutting-board movement speed, and shrinks the round timer (`clamp(7.0 / speed_multiplier, 3.0, 8.0)` seconds).
- **Direct Practice Mode / Microgame Selector**: On the title screen (and in the quick-bar below the canvas), you can either start a full 12-round campaign (`1.0x -> 2.5x`) or click any of the 5 microgames (`1. DODGE!`, `2. MASH!`, `3. CATCH!`, `4. TIMING!`, `5. SLICE!`) to practice it directly.
- **Persistent High Score & Best Streak (`localStorage`)**: Your highest score and longest consecutive microgame win streak are saved automatically across browser sessions.
- **Procedural Web Audio Retro Synth**: Instead of bundling heavy `.wav` or `.mp3` files, I wrote a real-time Web Audio synthesizer (`AudioContext`) using square, sawtooth, and triangle oscillators for win arpeggios (`C5 -> E5 -> G5`), fail buzzes, button-mash pops, and cleaver chops, with an instant mute toggle.
- **Hand-Written SVG Vector Art**: I wrote `assets/garlic.svg`, `assets/spike.svg`, and `assets/star.svg` directly as clean XML vector paths (`<path>`, `<polygon>`, cubic Bezier curves) so the sprites stay razor-sharp at any resolution with zero external asset packs.

---

## How I Built It & What Was Tricky to Debug

1. **Keeping High-Speed Rounds (`2.0x+`) Tough But Fair**:
   At first, when I scaled both hazard speed *and* the round countdown timer linearly with `speed_multiplier`, `DODGE!` and `MASH!` became nearly impossible past Round 8 (`2.2x` speed) because the timer dropped below 3 seconds while the mash quota doubled. I fixed this in `scripts/global.gd` by clamping `time_limit()` to a 3.0-second floor (`clampf(BASE_TIME / speed_multiplier, 3.0, 8.0)`) and tuning the `DODGE!` horizontal player movement speed so you can always outrun a worst-case spike spawn if you react cleanly.
2. **Preventing Double-Trigger Scene Transitions**:
   In `DODGE!` and `SLICE!`, if a spike hit you on the exact frame the timer reached `0.0`, `_win()` and `_fail()` could both fire during the same `_process(delta)` tick. Adding a `round_over` guard boolean at the top of `_win()`, `_fail()`, and `_process()` guaranteed that every microgame transitions cleanly to `timer_screen.tscn` exactly once.
3. **Syncing the Godot 4 Project with the Browser Build**:
   Because exporting a Godot 4 WebAssembly binary creates a multi-megabyte `.wasm` + `.pck` bundle with SharedArrayBuffer header quirks on static hosts, I also built `index.html` as a 60fps HTML5 Canvas + Web Audio implementation that mirrors the exact 640x360 coordinate space, SVG Bezier geometry, and `Global` state machine of my GDScript files. That way, anyone visiting [https://aariv.me/garlic-panic/](https://aariv.me/garlic-panic/) gets instant zero-wait gameplay on desktop or mobile, while the full Godot 4.7 project (`project.godot`, `scenes/`, `scripts/`, `tests/`) is right here in the repo.

---

## Controls

- **Move Left / Right** (`DODGE!`, `CATCH!`): `Left` / `Right` Arrow keys, `A` / `D`, or move your mouse/finger across the canvas
- **Action / Mash / Lock In / Chop** (`MASH!`, `TIMING!`, `SLICE!`): `SPACE`, `ENTER`, or Left Click / Tap

---

## How to Run It

### Option 1: Play Immediately in Your Browser
Visit **[https://aariv.me/garlic-panic/](https://aariv.me/garlic-panic/)** (or open `index.html` locally in any browser) to play the full 12-round campaign or practice any of the 5 microgames.

### Option 2: Open the Project in Godot 4
1. Download **Godot 4.x** from [godotengine.org/download](https://godotengine.org/download).
2. Open the Godot Project Manager, click **Import**, and select `project.godot` in this repository.
3. Press **F5** (or click the Play button) to launch `scenes/title_screen.tscn`.

You can also run the automated headless verification suite from the terminal:

```sh
Godot --headless --path . --import
Godot --headless --path . res://tests/smoke_test.tscn
Godot --headless --path . res://tests/autoplay.tscn
```

---

## Project Structure

```text
index.html             Playable HTML5 Canvas + Web Audio build (all 5 microgames + Practice Mode)
project.godot          Godot 4.7 project config (640x360 viewport, Global autoload)
scenes/                title_screen, timer_screen, themed_timer, minigame_1..5, done_screen, death_screen (.tscn)
scripts/               GDScript controllers for every scene + global.gd state machine
assets/                garlic.svg, spike.svg, star.svg (hand-written vector sprites)
tests/                 Headless smoke_test.tscn + autoplay.tscn verification scenes
screenshot1..6.png     Gameplay screenshots across microgames and intermission
BUILD-LOG.md           Step-by-step engineering log
```
