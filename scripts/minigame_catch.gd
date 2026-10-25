extends Node2D
## MINIGAME 3 - "CATCH!": move the paddle left/right with the arrow keys and
## catch the falling star before it hits the floor. Catch = win, miss = fail.

const PADDLE_SPEED := 320.0
const PADDLE_WIDTH := 90.0
const STAR_SIZE := Vector2(34.0, 34.0)
const FLOOR_Y := 330.0
const INSTRUCTION_TIME := 1.2

@onready var themed_timer: Node2D = $ThemedTimer
@onready var paddle: ColorRect = $Paddle
@onready var star: Sprite2D = $Star
@onready var instruction: RichTextLabel = $Instruction
@onready var hud_timer: RichTextLabel = $HudTimer
@onready var score_label: RichTextLabel = $Score

var star_speed: float = 200.0
var round_over: bool = false
var elapsed: float = 0.0
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	rng.randomize()
	star_speed = 200.0 * Global.speed_multiplier
	star.position = Vector2(rng.randf_range(60.0, 580.0), -20.0)
	themed_timer.start(Global.time_limit())
	instruction.text = "CATCH!"


func _process(delta: float) -> void:
	if round_over:
		return
	elapsed += delta
	instruction.visible = elapsed < INSTRUCTION_TIME
	hud_timer.text = "%.1f" % maxf(themed_timer.time_left, 0.0)
	score_label.text = "Score: %d" % Global.score

	var dir := Input.get_axis("ui_left", "ui_right")
	paddle.position.x = clampf(
		paddle.position.x + dir * PADDLE_SPEED * delta,
		10.0, 630.0 - PADDLE_WIDTH
	)

	star.position.y += star_speed * delta

	var star_rect := Rect2(star.position - STAR_SIZE * 0.5, STAR_SIZE)
	var paddle_rect := Rect2(paddle.position, paddle.size)
	if star_rect.intersects(paddle_rect):
		_win()
	elif star.position.y > FLOOR_Y:
		_fail()
	elif themed_timer.time_left <= 0.0:
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
