extends Node
## Global autoload - shared state for the whole WarioWare loop.
## Tracks lives, score, round counter, and the global speed multiplier
## across all 5 microgames (DODGE, MASH, CATCH, TIMING, SLICE).

const TOTAL_ROUNDS := 12         # rounds you must survive to reach the winner screen
const MAX_LIVES := 5             # five garlic cloves = five lives
const MINIGAME_COUNT := 5        # DODGE / MASH / CATCH / TIMING / SLICE
const BASE_TIME := 7.0           # seconds a microgame lasts at 1x speed

var score: int = 0               # successful microgames
var best_score: int = 0          # highest score this session
var streak: int = 0              # current consecutive wins
var best_streak: int = 0         # highest streak this session
var lives: int = MAX_LIVES
var minigames_done: int = 0
var speed_multiplier: float = 1.0
var last_result: String = ""     # "win" / "fail" / "" - read by the intermission flash


func reset() -> void:
	score = 0
	streak = 0
	lives = MAX_LIVES
	minigames_done = 0
	speed_multiplier = 1.0
	last_result = ""


func register_win() -> void:
	score += 1
	streak += 1
	if score > best_score:
		best_score = score
	if streak > best_streak:
		best_streak = streak
	minigames_done += 1
	speed_multiplier = minf(2.5, 1.0 + 0.15 * float(minigames_done))
	last_result = "win"


func register_fail() -> void:
	lives -= 1
	streak = 0
	last_result = "fail"


func current_level() -> int:
	return mini(minigames_done + 1, TOTAL_ROUNDS)


func minigame_index() -> int:
	return (minigames_done % MINIGAME_COUNT) + 1


func minigame_path() -> String:
	return "res://scenes/minigame_%d.tscn" % minigame_index()


func time_limit() -> float:
	## Microgames shrink their timer as the speed multiplier rises.
	return clampf(BASE_TIME / speed_multiplier, 3.0, 8.0)
