# Garlic Panic! - a WarioWare-style microgame collection

**Play Live in the Browser:** [https://aariv.me/garlic-panic/](https://aariv.me/garlic-panic/)

![Title screen](screenshot1.png)

![DODGE! in action](screenshot2.png)

A Hack Club **Stardance "Make a WarioWare Game" and "Make a WarioWare Game 2"** mission submission for **Aariv Patel**.
Built with **Godot 4.7** (GDScript), following the mission's 17-step guide, plus a self-contained HTML5 Canvas web build so you can play all four microgames directly in your browser.

Four frantic microgames chain together WarioWare-style - each one flashes its instruction, lasts a few seconds, and the whole game speeds up every round.

## The 4 Microgames

| # | Name | Scene | Command | Win condition |
|---|------|-------|---------|---------------|
| 1 | **DODGE!** | `scenes/minigame_1.tscn` | Left / Right (or A/D) to move | Survive the timer without touching a falling spike |
| 2 | **MASH!** | `scenes/minigame_2.tscn` | Mash SPACE (or click the garlic) | Hit the mash quota before the timer runs out |
| 3 | **CATCH!** | `scenes/minigame_3.tscn` | Left / Right (or A/D) to move paddle | Catch the falling star before it hits the floor |
| 4 | **TIMING!** | `scenes/minigame_4.tscn` | Press SPACE (or click LOCK IN) | Lock in while the oscillating marker is inside the green target zone |

## The WarioWare glue

- **Title screen** - Start Game / Settings (sound & fullscreen toggle) / Practice jump buttons.
- **Intermission** (`timer_screen`) - shows your 5 garlic lives, level number, score, speed multiplier, and a countdown before each microgame.
- **Speed multiplier** - every win raises a global speed multiplier (up to 2.5x): obstacles fall faster, the mash quota grows, the timing cursor sweeps faster, and each microgame's timer shrinks.
- **Score** - +1 per completed microgame, shown in the HUD and intermission.
- **Fail** - lose one garlic; the microgame replays. Out of garlic -> **GAME OVER** screen with Retry. Survive all 12 rounds -> **YOU WIN!** screen with Play Again.

## Controls

- **Arrow keys / A-D** - move (Dodge, Catch)
- **Space / Mouse Click** - mash (Mash) or lock in on the green target zone (Timing)

## How to run it

### Option 1: Play in your browser
Open [https://aariv.me/garlic-panic/](https://aariv.me/garlic-panic/) (or open `index.html` locally) to play all 4 microgames immediately with Web Audio retro sound effects.

### Option 2: Open in Godot 4
1. Download **Godot 4.x** (standard build, not .NET) from [godotengine.org/download](https://godotengine.org/download) - the mission guide uses Godot 4.
2. Open the Godot Project Manager -> **Import** -> select this folder's `project.godot`.
3. Press **F5** (or the Play button) to play.

Headless sanity checks used during development:

```sh
Godot --headless --path . --import                      # import assets
Godot --headless --path . --check-only --script res://scripts/global.gd   # lint any script
Godot --headless --path . --quit-after 120              # run main scene 120 frames
Godot --headless --path . res://tests/smoke_test.tscn   # instantiate every scene + state machine check
Godot --headless --path . res://tests/autoplay.tscn     # fast-forward the full game loop to GAME OVER
```

## Project layout

```
index.html             Self-contained HTML5 Canvas + Web Audio playable web build
project.godot          Godot 4 project (640x360, viewport stretch, Global autoload)
scenes/                title_screen, timer_screen, themed_timer, minigame_1..4, done_screen, death_screen (.tscn)
scripts/               one GDScript per scene + global.gd autoload
assets/                garlic.svg, spike.svg, star.svg (hand-written SVGs)
tests/                 headless smoke test + autoplay loop test
shots/                 raw captured frames (PNG sequences via --write-movie)
screenshot1..6.png     gameplay screenshots
BUILD-LOG.md           development log
```

## Honest AI note

This game was **built by AI coding agents under Aariv Patel's direction** as part of the Hack Club Stardance mission. All code, scenes, and SVG art in this repository were generated programmatically (no external art assets), and every scene was verified by running the Godot binary headless (import, per-script checks, frame runs, and an automated full-loop playthrough).

## Why I built this

The WarioWare missions asked for a microgame collection that gets faster and meaner every round. I built Garlic Panic around a garlic with five lives and four distinct microgames (DODGE, MASH, CATCH, TIMING) that speed up every round, because a game about pressure should be under pressure itself. The art is SVG written directly as code, with no asset packs.
