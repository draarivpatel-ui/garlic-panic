extends Node2D
## MINIGAME 5 - "SLICE!": A target kitchen ingredient and a friendly garlic bulb
## slide across the cutting board through the central CHOP ZONE under a chef's
## cleaver. Press SPACE or click CHOP! when the red target block is inside the
## green chop zone AND the garlic bulb is safely outside it.

const BOARD_LEFT := 90.0
const BOARD_RIGHT := 550.0
const CHOP_LEFT := 265.0
const CHOP_RIGHT := 375.0
const BASE_TARGET_SPEED := 320.0
const BASE_GARLIC_SPEED := 230.0
const ITEM_HALF_WIDTH := 18.0
const INSTRUCTION_TIME := 1.2

@onready var themed_timer: Node2D = $ThemedTimer
@onready var chop_zone: ColorRect = $ChopZone
@onready var target_item: ColorRect = $TargetItem
@onready var garlic_hazard: Sprite2D = $GarlicHazard
@onready var cleaver_blade: ColorRect = $CleaverBlade
@onready var chop_button: Button = $ChopButton
@onready var instruction: RichTextLabel = $Instruction
@onready var hud_timer: RichTextLabel = $HudTimer
@onready var score_label: RichTextLabel = $Score

var target_x: float = 140.0
var target_dir: float = 1.0
var target_speed: float = 320.0

var garlic_x: float = 510.0
var garlic_dir: float = -1.0
var garlic_speed: float = 230.0

var round_over: bool = false
var elapsed: float = 0.0


func _ready() -> void:
	target_speed = BASE_TARGET_SPEED * Global.speed_multiplier
	garlic_speed = BASE_GARLIC_SPEED * Global.speed_multiplier
	target_x = 150.0
	target_dir = 1.0
	garlic_x = 510.0
	garlic_dir = -1.0
	_update_visuals()
	themed_timer.start(Global.time_limit())
	instruction.text = "SLICE!"
	chop_button.pressed.connect(_on_chop)


func _process(delta: float) -> void:
	if round_over:
		return
	elapsed += delta
	instruction.visible = elapsed < INSTRUCTION_TIME
	hud_timer.text = "%.1f" % maxf(themed_timer.time_left, 0.0)
	score_label.text = "Score: %d" % Global.score

	target_x += target_dir * target_speed * delta
	if target_x >= BOARD_RIGHT:
		target_x = BOARD_RIGHT
		target_dir = -1.0
	elif target_x <= BOARD_LEFT:
		target_x = BOARD_LEFT
		target_dir = 1.0

	garlic_x += garlic_dir * garlic_speed * delta
	if garlic_x >= BOARD_RIGHT:
		garlic_x = BOARD_RIGHT
		garlic_dir = -1.0
	elif garlic_x <= BOARD_LEFT:
		garlic_x = BOARD_LEFT
		garlic_dir = 1.0

	_update_visuals()

	if Input.is_action_just_pressed("ui_accept"):
		_on_chop()
		return

	if themed_timer.time_left <= 0.0:
		_fail()


func _update_visuals() -> void:
	target_item.position.x = target_x - ITEM_HALF_WIDTH
	garlic_hazard.position.x = garlic_x


func _on_chop() -> void:
	if round_over:
		return
	cleaver_blade.position.y = 178.0
	var garlic_in_zone := garlic_x >= (CHOP_LEFT - 12.0) and garlic_x <= (CHOP_RIGHT + 12.0)
	var target_in_zone := target_x >= CHOP_LEFT and target_x <= CHOP_RIGHT
	if garlic_in_zone:
		_fail()
	elif target_in_zone:
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
