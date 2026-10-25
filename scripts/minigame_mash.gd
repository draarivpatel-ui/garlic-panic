extends Node2D
## MINIGAME 2 - "MASH!": press SPACE (or click the garlic button, like the
## guide's clicker minigame) enough times before the themed timer runs out.
## The required mash count grows with the speed multiplier.

const INSTRUCTION_TIME := 1.2

@onready var themed_timer: Node2D = $ThemedTimer
@onready var mash_button: TextureButton = $MashButton
@onready var progress_label: RichTextLabel = $Progress
@onready var instruction: RichTextLabel = $Instruction
@onready var hud_timer: RichTextLabel = $HudTimer
@onready var score_label: RichTextLabel = $Score

var target: int = 10
var presses: int = 0
var round_over: bool = false
var elapsed: float = 0.0


func _ready() -> void:
	target = int(ceilf(10.0 * Global.speed_multiplier))
	themed_timer.start(Global.time_limit())
	instruction.text = "MASH!"
	mash_button.pressed.connect(_on_mash_pressed)
	_update_progress()


func _process(delta: float) -> void:
	if round_over:
		return
	elapsed += delta
	instruction.visible = elapsed < INSTRUCTION_TIME
	hud_timer.text = "%.1f" % maxf(themed_timer.time_left, 0.0)
	score_label.text = "Score: %d" % Global.score

	if Input.is_action_just_pressed("ui_accept"):
		_register_press()

	if presses >= target:
		_win()
	elif themed_timer.time_left <= 0.0:
		_fail()


func _on_mash_pressed() -> void:
	if round_over:
		return
	_register_press()
	if presses >= target:
		_win()


func _register_press() -> void:
	presses += 1
	_update_progress()
	mash_button.scale = Vector2(0.9, 0.9)
	var squash := create_tween()
	squash.tween_property(mash_button, "scale", Vector2.ONE, 0.08)


func _update_progress() -> void:
	progress_label.text = "%d / %d" % [presses, target]


func _win() -> void:
	if round_over:
		return
	round_over = true
	Global.register_win()
	get_tree().change_scene_to_file("res://scenes/timer_screen.tscn")


func _fail() -> void:
	if round_over:
		return
	round_over = true
	Global.register_fail()
	get_tree().change_scene_to_file("res://scenes/timer_screen.tscn")
