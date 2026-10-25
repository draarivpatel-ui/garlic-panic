extends Node
## Autoplay test launcher (not part of the game).
## Run with:
##   Godot --headless --path <project> res://tests/autoplay.tscn
## Spawns a driver node directly under root so it survives scene changes,
## then hands control to it.


func _ready() -> void:
	var driver := Node.new()
	driver.name = "AutoplayDriver"
	driver.set_script(load("res://tests/autoplay_driver.gd"))
	get_tree().root.add_child.call_deferred(driver)
