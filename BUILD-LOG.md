# BUILD-LOG.md - Garlic Panic! (Stardance WarioWare mission)

Devlog-sized, numbered, dated. All work on 2026-10-24.

## 1. Reading the mission guide

The Stardance mission page ("Make a WarioWare Game") links a 17-step guide. The
`hackclub/jams` GitHub repo has no `wario-ware` folder, so the guide was read
straight from the public mission page (no login). Extracted steps:

1. How to Make Your First WarioWare-style Game (intro)
2. Setting Up Godot (Godot 4, latest)
3. Downloading GitHub Desktop
4. Putting the GitHub project into our Local Repository
5. Creating the Start Menu (TitleScreen: background, title label, Start/Settings/Quit)
6. Committing and Pushing to GitHub
7. Creating a Global Script (autoload: `minigames_done`, `lives = 5`)
8. Creating the Level Scene (5 garlic lives, level number, timer)
9. Programming the Level Scene (countdown → next minigame / end screens)
10. Creating a Themed Timer (reusable countdown scene)
11. Creating a Platformer Minigame (player + platforms + collectibles)
12. Programming the Platformer Minigame
13. Creating a Clicker Minigame (press all the buttons in time)
14. Programming the Clicker Minigame
15. Challenge: Creating the Winner and Death Screens
16. Expanding the Game (add a third minigame)
17. Publishing and Submitting Your Game (Web export → itch.io)

**Stack per the guide:** Godot 4 + GDScript, scenes saved as `.tscn`, a `Global`
autoload, scene names `minigame_1..N`, and a Web export for itch.io.

## 2. Installing Godot locally (no sudo)

- Pulled the latest stable 4.x from GitHub releases: `Godot_v4.7.2-stable_macos.universal.zip`.
- Unzipped into a local tools folder (`tools/godot/Godot.app`), cleared quarantine
  (`xattr -dr com.apple.quarantine` - curl doesn't stamp it, cleared anyway).
- `./Godot.app/Contents/MacOS/Godot --version` → `4.7.2.stable.official.ed1daf0bf`.

## 3. Building the game

Followed the guide's architecture, with the guide's three microgame styles
realized as DODGE / MASH / CATCH:

- `project.godot` - 640×360, viewport stretch ("Stretch to Fit" fix from the
  guide), main scene = title screen, `Global` autoload registered.
- `scripts/global.gd` - the guide's Global script (`lives = 5`,
  `minigames_done`) plus `score` and a `speed_multiplier` that rises 0.15 per
  win (cap 2.5x). Faster multiplier = faster obstacles, bigger mash quota,
  shorter microgame timers (`7.0s / multiplier`, clamped 3-8s).
- `scenes/title_screen.tscn` - title, garlic icon, Start/Settings/Quit exactly
  like the guide's Start Menu step; Settings opens a panel with a fullscreen
  toggle. Signals connected in `_ready()` (code equivalent of the editor's
  Signals tab).
- `scenes/timer_screen.tscn` - the guide's intermission: HBox of 5 garlic
  lives, level number, score, big countdown, GET READY flash. Dispatches to
  `minigame_<n>` by rotating `(minigames_done % 3) + 1`; lives 0 → death
  screen; 9 rounds survived → winner screen.
- `scenes/themed_timer.tscn` + `scripts/themed_timer.gd` - the guide's reusable
  Themed Timer: countdown label snapped to 0.1s (`str(snapped(time, 0.1))`),
  started with `start(seconds)`, exposes `time_left` and a `timed_out` signal.
  Deliberately poll-based instead of the guide's `await` coroutine so a
  microgame can win/lose early without dangling coroutines.
- `scenes/minigame_1.tscn` - **DODGE!**: garlic player moves with ←/→, spikes
  fall at `speed × multiplier`, collision is plain `Rect2.intersects()` math
  (no physics needed). Survive the timer = win.
- `scenes/minigame_2.tscn` - **MASH!**: the guide's clicker minigame as a mash:
  TextureButton garlic + SPACE both count toward a quota that grows with the
  multiplier (`10 × multiplier`). Button has a little squash tween for juice.
- `scenes/minigame_3.tscn` - **CATCH!**: the guide's "Expanding the Game" third
  minigame - paddle moves ←/→, star falls at `200 × multiplier` px/s. Catch =
  win, floor = fail.
- `scenes/done_screen.tscn` / `scenes/death_screen.tscn` - the guide's
  Challenge step: YOU WIN / GAME OVER, both with restart (Play Again / Retry)
  and Title Menu buttons.
- Instruction flashes ("DODGE!", "MASH!", "CATCH!") show for the first 1.2s of
  every microgame, WarioWare-style.

Art is hand-written SVG (garlic, spike, star, icon) - no external assets.

## 4. Verification (real Godot binary, all headless)

Ran the local `Godot.app/Contents/MacOS/Godot` binary:

- `--headless --path . --import` → exit 0, all 4 SVGs imported, zero errors.
- `--headless --path . --check-only --script res://scripts/<each>.gd` → all 9
  game scripts pass with exit 0.
- `--headless --path . --quit-after 120` (title) → exit 0, clean.
- `--headless --path . res://scenes/<scene>.tscn --quit-after 180` for the six
  other scenes → all exit 0, clean.
- `res://tests/smoke_test.tscn` (new): loads + instantiates all 8 scenes under
  the live autoload and runs the Global state machine (9 wins → speed 2.35,
  5 fails → lives 0) → `SMOKE: ALL CHECKS PASSED`, exit 0.
- `res://tests/autoplay.tscn` (new): fast-forwards the real game loop -
  Minigame1 → intermission → Minigame2 → … → DeathScreen with `lives=0`.
  Verified the win path (score +1, rotation advances) and fail path (garlic
  lost, level replays) end to end. Exit 0.
- 60-second headless playthrough (`--quit-after 3600` from minigame_1) → exit 0.

First smoke-test attempt (`--script` mode) taught us that custom-MainLoop
scripts don't register autoloads, so scripts referencing `Global` can't compile
there - rewrote the test as a scene that runs in normal game mode. Also fixed
an autoplay-harness bug: re-arming the themed timer every frame kept it from
ever hitting zero (the game logic itself was correct).

## 5. Screenshots

- `--headless --write-movie` crashes (dummy renderer has no textures -
  `texture_2d_get` null, signal 11). Known Godot limitation, noted honestly.
- Windowed Movie Maker PNG sequences worked instead: captured 500 real frames
  across title / intermission / dodge / mash / catch / gameover / winner
  (`shots/<name>/fNNNNNNNN.png`).
- Spotted RichTextLabel scrollbars in the first batch → set
  `scroll_active = false` on every label and recaptured.
- Copied 6 good frames to `screenshot1..6.png` (title, dodge flash, mash,
  catch, intermission, game over).

## 6. Wrapping up

README.md written (how to run, controls, AI note: "built by AI coding agents
under Aariv Patel's direction"). No git commits/pushes were made, per mission
rules - Billy (Aariv) handles tracked minutes, the GitHub repo, Web export →
itch.io publish, and the Stardance submission.
