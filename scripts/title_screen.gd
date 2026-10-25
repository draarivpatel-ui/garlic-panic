extends Control
## Title screen - the guide's "Creating the Start Menu" step:
## a title, a Start button, a Settings panel and a Quit button.

@onready var start_button: Button = $Buttons/Start
@onready var settings_button: Button = $Buttons/Settings
@onready var quit_button: Button = $Buttons/Quit
@onready var settings_panel: Panel = $SettingsPanel
@onready var back_button: Button = $SettingsPanel/Back
@onready var fullscreen_check: CheckBox = $SettingsPanel/FullscreenCheck


func _ready() -> void:
	start_button.pressed.connect(_on_start_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	back_button.pressed.connect(_on_back_pressed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	settings_panel.visible = false


func _on_start_pressed() -> void:
	Global.reset()
	get_tree().change_scene_to_file("res://scenes/timer_screen.tscn")


func _on_settings_pressed() -> void:
	settings_panel.visible = true


func _on_back_pressed() -> void:
	settings_panel.visible = false


func _on_fullscreen_toggled(pressed: bool) -> void:
	if pressed:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		get_window().mode = Window.MODE_WINDOWED


func _on_quit_pressed() -> void:
	get_tree().quit()
