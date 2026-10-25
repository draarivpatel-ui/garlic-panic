extends Control
## Winner screen - the guide's "Challenge: Creating the Winner and Death
## Screens". Shown after surviving every round, with restart options.

@onready var score_label: RichTextLabel = $Score
@onready var play_again_button: Button = $Buttons/PlayAgain
@onready var menu_button: Button = $Buttons/Menu


func _ready() -> void:
	score_label.text = "Score: %d   |   Survived %d rounds" % [
		Global.score, Global.TOTAL_ROUNDS
	]
	play_again_button.pressed.connect(_on_play_again_pressed)
	menu_button.pressed.connect(_on_menu_pressed)


func _on_play_again_pressed() -> void:
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/timer_screen.tscn")


func _on_menu_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/title_screen.tscn")
