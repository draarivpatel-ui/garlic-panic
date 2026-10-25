extends Node2D
## Intermission scene (the guide's "timer_screen"): shows the five garlic
## lives, the level number, the score and a countdown, then dispatches the
## player to the next microgame (or an end screen). This is the WarioWare
## "glue" between microgames.

@onready var garlic_container: HBoxContainer = $GarlicContainer
@onready var garlics: Array = [
	$GarlicContainer/Garlic1,
	$GarlicContainer/Garlic2,
	$GarlicContainer/Garlic3,
	$GarlicContainer/Garlic4,
	$GarlicContainer/Garlic5,
]
@onready var level_label: RichTextLabel = $Level
@onready var timer_label: RichTextLabel = $Timer
@onready var ready_label: RichTextLabel = $GetReady
@onready var score_label: RichTextLabel = $Score
@onready var result_label: RichTextLabel = $Result

var time_left: float = 3.0
var dispatched: bool = false


func _ready() -> void:
	if Global.last_result == "fail":
		result_label.text = "MISSED!  -1 garlic"
		result_label.visible = true
	elif Global.last_result == "win":
		result_label.text = "NICE!"
		result_label.visible = true
	else:
		result_label.visible = false

	level_label.text = "Level %d" % Global.current_level()
	score_label.text = "Score: %d" % Global.score
	_update_garlics()

	if Global.lives <= 0:
		ready_label.text = "OUT OF GARLIC..."
	elif Global.minigames_done >= Global.TOTAL_ROUNDS:
		ready_label.text = "YOU SURVIVED!"
	else:
		ready_label.text = "GET READY..."


func _update_garlics() -> void:
	for i in garlics.size():
		garlics[i].visible = i < Global.lives
	if Global.lives <= 0:
		garlic_container.visible = false


func _process(delta: float) -> void:
	time_left -= delta
	timer_label.text = str(snapped(maxf(time_left, 0.0), 0.1))
	if time_left <= 0.0 and not dispatched:
		dispatched = true
		_advance()


func _advance() -> void:
	if Global.lives <= 0:
		get_tree().change_scene_to_file("res://scenes/death_screen.tscn")
	elif Global.minigames_done >= Global.TOTAL_ROUNDS:
		get_tree().change_scene_to_file("res://scenes/done_screen.tscn")
	else:
		get_tree().change_scene_to_file(Global.minigame_path())
