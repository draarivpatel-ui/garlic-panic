# BUILD-LOG.md - Garlic Panic! (Stardance WarioWare mission)

Devlog-sized, numbered, dated. Work completed on 2026-10-24 and 2026-10-25.

## 1. Reading the mission guide

The Stardance mission page ("Make a WarioWare Game" and "Make a WarioWare Game 2") links a 17-step guide. Extracted steps:

1. How to Make Your First WarioWare-style Game (intro)
2. Setting Up Godot (Godot 4, latest)
3. Downloading GitHub Desktop
4. Putting the GitHub project into our Local Repository
5. Creating the Start Menu (TitleScreen: background, title label, Start/Settings/Quit)
6. Committing and Pushing to GitHub
7. Creating a Global Script (autoload: `minigames_done`, `lives = 5`)
8. Creating the Level Scene (5 garlic lives, level number, timer)
9. Programming the Level Scene (countdown -> next minigame / end screens)
10. Creating a Themed Timer (reusable countdown scene)
11. Creating a Platformer Minigame (player + platforms + collectibles)
12. Programming the Platformer Minigame
13. Creating a Clicker Minigame (press all the buttons in time)
14. Programming the Clicker Minigame
15. Challenge: Creating the Winner and Death Screens
16. Expanding the Game (add third and fourth minigames)
17. Publishing and Submitting Your Game (Web build + GitHub Pages)

**Stack per the guide:** Godot 4 + GDScript, scenes saved as `.tscn`, a `Global` autoload, scene names `minigame_1..4`, plus an HTML5 web build hosted at `https://aariv.me/garlic-panic/`.

## 2. Installing Godot locally (no sudo)

- Pulled the latest stable 4.x from GitHub releases: `Godot_v4.7.2-stable_macos.universal.zip`.
- Unzipped into a local tools folder (`tools/godot/Godot.app`), cleared quarantine.
- `./Godot.app/Contents/MacOS/Godot --version` -> `4.7.2.stable.official.ed1daf0bf`.

## 3. Building the 4 microgames and WarioWare loop

Followed the guide's architecture with four distinct microgames realized as DODGE / MASH / CATCH / TIMING:

- `project.godot` - 640x360, viewport stretch ("Stretch to Fit" fix from the guide), main scene = title screen, `Global` autoload registered.
- `scripts/global.gd` - the guide's Global script (`lives = 5`, `minigames_done`, `MINIGAME_COUNT = 4`, `TOTAL_ROUNDS = 12`) plus `score` and a `speed_multiplier` that rises 0.15 per win (cap 2.5x). Faster multiplier = faster obstacles, bigger mash quota, faster timing sweep, shorter microgame timers (`7.0s / multiplier`, clamped 3-8s).
- `scenes/title_screen.tscn` - title, garlic icon, Start/Settings/Quit exactly like the guide's Start Menu step; Settings opens a panel with a fullscreen toggle.
- `scenes/timer_screen.tscn` - the guide's intermission: HBox of 5 garlic lives, level number, score, big countdown, GET READY flash. Dispatches to `minigame_<n>` by rotating `(Global.minigames_done % 4) + 1`; lives 0 -> death screen; 12 rounds survived -> winner screen.
- `scenes/themed_timer.tscn` + `scripts/themed_timer.gd` - the guide's reusable Themed Timer: countdown label snapped to 0.1s (`str(snapped(time, 0.1))`), started with `start(seconds)`, exposes `time_left` and a `timed_out` signal.
- `scenes/minigame_1.tscn` - **DODGE!**: garlic player moves with Left/Right, spikes fall at `speed * multiplier`, collision is plain `Rect2.intersects()` math. Survive the timer = win.
- `scenes/minigame_2.tscn` - **MASH!**: the guide's clicker minigame as a mash: TextureButton garlic + SPACE both count toward a quota that grows with the multiplier (`10 * multiplier`). Button has a squash tween for juice.
- `scenes/minigame_3.tscn` - **CATCH!**: paddle moves Left/Right, star falls at `200 * multiplier` px/s. Catch = win, floor = fail.
- `scenes/minigame_4.tscn` + `scripts/minigame_4.gd` - **TIMING!** (`LOCK IN!`): an oscillating marker sweeps left and right across a bar at `380 * multiplier` px/s with a central green target zone. Pressing SPACE or clicking LOCK IN while the marker is inside the green target zone wins the round; pressing outside or letting the timer expire loses a garlic life.
- `scenes/done_screen.tscn` / `scenes/death_screen.tscn` - YOU WIN / GAME OVER, both with restart (Play Again / Retry) and Title Menu buttons.
- `index.html` - self-contained HTML5 Canvas + Web Audio playable build rendering the exact 640x360 viewport, SVG vector paths (`garlic.svg`, `spike.svg`, `star.svg`), intermission screen, and all 4 microgames directly in the browser at `https://aariv.me/garlic-panic/`.

## 4. Verification

- Headless smoke test (`tests/smoke_test.gd`) updated to verify 12 wins rotation across `minigame_1..4` and instantiate all 9 `.tscn` scenes (`title_screen`, `timer_screen`, `themed_timer`, `minigame_1`, `minigame_2`, `minigame_3`, `minigame_4`, `done_screen`, `death_screen`).
- Autoplay harness (`tests/autoplay_driver.gd`) updated to step through all 4 microgames.
- Web build (`index.html`) verified in headless browser and deployed via GitHub Pages to `https://aariv.me/garlic-panic/`.

## 5. Screenshots

- Windowed Movie Maker PNG sequences captured across title / intermission / dodge / mash / catch / gameover / winner (`shots/<name>/fNNNNNNNN.png`).
- Copied 6 frames to `screenshot1..6.png` (title, dodge flash, mash, catch, intermission, game over).
