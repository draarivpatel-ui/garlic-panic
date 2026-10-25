extends Node2D
## MINIGAME 4 - "TIMING!" (LOCK IN!): an oscillating marker sweeps left-and-right
## across a bar with a central green target zone. Press SPACE or click when the
## marker is inside the target zone to win; pressing outside or running out of
## time loses a garlic life. Marker speed scales with Global.speed_multiplier.

const BAR_LEFT := 100.0
const BAR_RIGHT := 540.0
const TARGET_LEFT := 270.0
const TARGET_RIGHT := 370.0
const BASE_SWEEP_SPEED := 380.0
const MARKER_HALF_WIDTH := 6.0
const INSTRUCTION_TIME := 1.2

@onready var themed_timer: Node2D = $ThemedTimer
@onready var target_zone: ColorRect = $TargetZone
@onready var marker: ColorRect = $Marker
@onready var lock_button: Button = $LockButton
@onready var instruction: RichTextLabel = $Instruction
@onready var hud_timer: RichTextLabel = $HudTimer
@onready var score_label: RichTextLabel = $Score

var marker_x: float = 120.0
var sweep_dir: float = 1.0
var sweep_speed: float = 380.0
var round_over: bool = false
var elapsed: float = 0.0


func _ready() -> void:
	sweep_speed = BASE_SWEEP_SPEED * Global.speed_multiplier
	marker_x = BAR_LEFT + 20.0
	sweep_dir = 1.0
	_update_marker_visual()
	themed_timer.start(Global.time_limit())
	instruction.text = "TIMING!"
	lock_button.pressed.connect(_on_attempt)


func _process(delta: float) -> void:
	if round_over:
		return
	elapsed += delta
	instruction.visible = elapsed < INSTRUCTION_TIME
	hud_timer.text = "%.1f" % maxf(themed_timer.time_left, 0.0)
	score_label.text = "Score: %d" % Global.score

	marker_x += sweep_dir * sweep_speed * delta
	if marker_x >= BAR_RIGHT:
		marker_x = BAR_RIGHT
		sweep_dir = -1.0
	elif marker_x <= BAR_LEFT:
		marker_x = BAR_LEFT
		sweep_dir = 1.0
	_update_marker_visual()

	if Input.is_action_just_pressed("ui_accept"):
		_on_attempt()
		return

	if themed_timer.time_left <= 0.0:
		_fail()


func _update_marker_visual() -> void:
	marker.position.x = marker_x - MARKER_HALF_WIDTH


func _on_attempt() -> void:
	if round_over:
		return
	if marker_x >= TARGET_LEFT and marker_x <= TARGET_RIGHT:
		_win()
	else:
		_fail()


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
