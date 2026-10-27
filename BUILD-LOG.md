# BUILD-LOG.md - Garlic Panic!

My development log for building **Garlic Panic!** for the Hack Club Stardance WarioWare missions.

## 1. Planning the WarioWare Loop & Architecture

I started by mapping out the 17 steps of the Stardance WarioWare guide and deciding how I wanted my microgame rush to feel:
- **Core premise**: You play as a 5-clove garlic bulb (`lives = 5`) surviving 12 kitchen rounds (`TOTAL_ROUNDS = 12`).
- **Global state (`scripts/global.gd`)**: Tracks `score`, `best_score`, `streak`, `best_streak`, `lives`, `minigames_done`, and `speed_multiplier` (which starts at `1.0x` and climbs `+0.15x` after every win up to `2.5x`).
- **Reusable timer (`scenes/themed_timer.tscn` + `scripts/themed_timer.gd`)**: Displays a 0.1s-snapped countdown (`str(snapped(time, 0.1))`) and emits `timed_out` when time expires.

## 2. Building All 5 Microgames

1. **`minigame_1` - `DODGE!`**:
   - Built a horizontal movement controller (`280 px/s`) for the garlic player at `y = 310`.
   - Falling crimson spikes spawn at intervals scaled by `1.0 / Global.speed_multiplier` and fall at `(170..260) * Global.speed_multiplier` px/s.
   - Surviving until `time_left <= 0` registers a win.
2. **`minigame_2` - `MASH!`**:
   - Built a button-masher where pressing `SPACE` or clicking the central garlic bulb increments `presses` toward `ceil(10 * Global.speed_multiplier)`.
   - Added a squash-and-stretch scale bounce (`0.86x` recovering smoothly to `1.0x`) so every press feels snappy.
3. **`minigame_3` - `CATCH!`**:
   - Built a sliding kitchen paddle (`90x14` at `y = 316`) that moves left and right to catch a golden star dropping at `200 * Global.speed_multiplier` px/s.
4. **`minigame_4` - `TIMING!`**:
   - Built a reflex lock-in bar (`x = 100..540`) with a central green target zone (`x = 270..370`) and a marker sweeping at `380 * Global.speed_multiplier` px/s.
   - Pressing `SPACE` or clicking `LOCK IN!` inside the green zone wins immediately; pressing outside loses a clove.
5. **`minigame_5` - `SLICE!`**:
   - Built a cutting-board microgame where a red tomato target (`320 * Global.speed_multiplier` px/s) and a friendly garlic decoy (`230 * Global.speed_multiplier` px/s) slide across a central green chop zone (`x = 265..375`) under a chef's cleaver.
   - Pressing `SPACE` or clicking `CHOP!` slams the cleaver down: chopping the tomato while the garlic is clear wins the round, while accidentally chopping the garlic loses a life.

## 3. Hand-Written SVG Sprites & HTML5 Canvas + Web Audio Build

- Wrote `assets/garlic.svg`, `assets/spike.svg`, and `assets/star.svg` directly as clean XML vector paths.
- Built `index.html` with a 640x360 HiDPI HTML5 Canvas renderer, a Web Audio API retro sound synthesizer, persistent `localStorage` High Score and Best Streak tracking, and an interactive Practice Mode selector on the title screen so players can jump directly into any of the 5 microgames.
- Verified all 10 Godot `.tscn` scenes using `tests/smoke_test.tscn`.
