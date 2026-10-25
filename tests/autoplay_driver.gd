extends Node
## Autoplay driver (not part of the game). Lives under root, survives scene
## changes, fast-forwards through the WarioWare fail loop and asserts that
## the game reaches the death screen. Quits 0 on success.
##
## Fast-forwarding happens exactly once per scene visit: SceneTree.process_frame
## fires before nodes' _process, and re-arming the themed timer every frame
## would keep it from ever reaching zero.

const MICROGAMES := ["Minigame1", "Minigame2", "Minigame3"]


func _ready() -> void:
	await get_tree().process_frame
	get_tree().change_scene_to_file("res://scenes/minigame_1.tscn")
	await get_tree().process_frame
	await get_tree().process_frame

	var last_scene := ""
	var transitions := 0
	for i in 400:
		var cs := get_tree().current_scene
		if cs == null:
			await get_tree().process_frame
			continue
		var scene_name := String(cs.name)
		if scene_name != last_scene:
			print("AUTOPLAY: scene -> ", scene_name)
			last_scene = scene_name
			transitions += 1
			if scene_name == "TimerScreen":
				cs.time_left = 0.0
			elif scene_name in MICROGAMES:
				cs.themed_timer.time_left = 0.0
		elif scene_name == "DeathScreen":
			break
		await get_tree().process_frame

	var g: Node = get_node("/root/Global")
	print("AUTOPLAY: transitions=", transitions, " lives=", g.lives,
			" score=", g.score, " last_scene=", last_scene)
	if last_scene == "DeathScreen" and g.lives <= 0:
		print("AUTOPLAY: FAIL LOOP VERIFIED (death screen reached)")
		get_tree().quit(0)
	else:
		print("AUTOPLAY FAIL: stuck at ", last_scene)
		get_tree().quit(1)
