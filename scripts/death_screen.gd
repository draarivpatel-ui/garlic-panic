extends Control
## Game-over screen - the guide's "Challenge: Creating the Winner and Death
## Screens". Shown when the garlic runs out, with a restart button.

@onready var score_label: RichTextLabel = $Score
@onready var retry_button: Button = $Buttons/Retry
@onready var menu_button: Button = $Buttons/Menu


func _ready() -> void:
	score_label.text = "Score: %d   |   Reached level %d" % [
		Global.score, Global.current_level()
	]
	retry_button.pressed.connect(_on_retry_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _on_retry_pressed() -> void:
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/timer_screen.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
