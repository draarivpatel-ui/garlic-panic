extends Node2D
## MINIGAME 6 - "SORT!": Sort 4 kitchen items into the right bin before time runs out.
## Press LEFT (Left Arrow / A) or click GARLIC BIN when a garlic bulb is shown.
## Press RIGHT (Right Arrow / D) or click TOMATO BIN when a red tomato is shown.

const TARGET_SORTS := 4
const INSTRUCTION_TIME := 1.2

@onready var themed_timer: Node2D = $ThemedTimer
@onready var garlic_sprite: Sprite2D = $GarlicItem
@onready var tomato_rect: ColorRect = $TomatoItem
@onready var left_btn: Button = $LeftBinButton
@onready var right_btn: Button = $RightBinButton
@onready var progress_label: RichTextLabel = $ProgressLabel
@onready var instruction: RichTextLabel = $Instruction
@onready var hud_timer: RichTextLabel = $HudTimer
@onready var score_label: RichTextLabel = $Score

var sorted_count: int = 0
var current_is_garlic: bool = true
var round_over: bool = false
var elapsed: float = 0.0


func _ready() -> void:
	sorted_count = 0
	_pick_next_item()
	themed_timer.start(Global.time_limit())
	instruction.text = "SORT!"
	left_btn.pressed.connect(func(): _sort_choice(true))
	right_btn.pressed.connect(func(): _sort_choice(false))


func _pick_next_item() -> void:
	current_is_garlic = randf() < 0.5
	garlic_sprite.visible = current_is_garlic
	tomato_rect.visible = not current_is_garlic
	progress_label.text = "Sorted: %d / %d" % [sorted_count, TARGET_SORTS]


func _process(delta: float) -> void:
	if round_over:
		return
	elapsed += delta
	instruction.visible = elapsed < INSTRUCTION_TIME
	hud_timer.text = "%.1f" % maxf(themed_timer.time_left, 0.0)
	score_label.text = "Score: %d" % Global.score

	if Input.is_action_just_pressed("ui_left"):
		_sort_choice(true)
		return
	if Input.is_action_just_pressed("ui_right"):
		_sort_choice(false)
		return

	if themed_timer.time_left <= 0.0:
		_fail()


func _sort_choice(chose_garlic_bin: bool) -> void:
	if round_over:
		return
	if chose_garlic_bin == current_is_garlic:
		sorted_count += 1
		if sorted_count >= TARGET_SORTS:
			_win()
		else:
			_pick_next_item()
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
