extends Node
## Headless smoke test scene (not part of the game).
## Run with:
##   Godot --headless --path <project> res://tests/smoke_test.tscn
## Runs in normal game mode, so the Global autoload is live.
## Instantiates every scene, lets its _ready run, and exercises the
## Global state machine. Quits 0 on success, 1 on failure.

const SCENES := [
	"res://scenes/title_screen.tscn",
	"res://scenes/timer_screen.tscn",
	"res://scenes/themed_timer.tscn",
	"res://scenes/minigame_1.tscn",
	"res://scenes/minigame_2.tscn",
	"res://scenes/minigame_3.tscn",
	"res://scenes/minigame_4.tscn",
	"res://scenes/done_screen.tscn",
	"res://scenes/death_screen.tscn",
]


func _ready() -> void:
	var failures := 0

	# --- Global state machine (live autoload) ---
	var g: Node = get_node("/root/Global")
	g.reset()
	for i in 12:
		g.register_win()
	if g.score != 12 or g.minigames_done != 12 or g.speed_multiplier <= 1.0:
		print("SMOKE FAIL: win path broken. score=", g.score,
				" done=", g.minigames_done, " speed=", g.speed_multiplier)
		failures += 1
	else:
		print("SMOKE OK: 12 wins -> score=", g.score, " speed=", g.speed_multiplier,
				" time_limit=", g.time_limit())
	if g.minigame_path() != "res://scenes/minigame_1.tscn":
		print("SMOKE FAIL: rotation path wrong: ", g.minigame_path())
		failures += 1

	g.reset()
	for i in 5:
		g.register_fail()
	if g.lives > 0:
		print("SMOKE FAIL: 5 fails should empty lives, got ", g.lives)
		failures += 1
	else:
		print("SMOKE OK: 5 fails -> lives=", g.lives, " (death screen path)")

	# --- Every scene must load, instantiate and survive its _ready ---
	for path in SCENES:
		var ps: PackedScene = load(path)
		if ps == null:
			print("SMOKE FAIL: could not load ", path)
			failures += 1
			continue
		var inst: Node = ps.instantiate()
		if inst == null:
			print("SMOKE FAIL: could not instantiate ", path)
			failures += 1
			continue
		add_child(inst)
		await get_tree().process_frame
		await get_tree().process_frame
		if not is_instance_valid(inst) or not inst.is_inside_tree():
			print("SMOKE FAIL: ", path, " did not survive _ready")
			failures += 1
			continue
		print("SMOKE OK: ", path, " -> ", inst.name, " (",
				inst.get_child_count(), " children)")
		inst.queue_free()
		await get_tree().process_frame

	if failures == 0:
		print("SMOKE: ALL CHECKS PASSED")
		get_tree().quit(0)
	else:
		print("SMOKE: ", failures, " FAILURES")
		get_tree().quit(1)
