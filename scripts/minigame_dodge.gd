extends Node2D
## MINIGAME 1 - "DODGE!": move left/right with the arrow keys and survive
## the timer without touching the falling spikes. Survive = win, hit = fail.

const PLAYER_SPEED := 280.0
const PLAYER_HALF := Vector2(14.0, 14.0)   # forgiving hitbox half-extents
const SPIKE_SIZE := Vector2(26.0, 26.0)
const INSTRUCTION_TIME := 1.2              # how long the "DODGE!" flash stays up

@onready var themed_timer: Node2D = $ThemedTimer
@onready var player: Sprite2D = $Player
@onready var obstacles: Node2D = $Obstacles
@onready var instruction: RichTextLabel = $Instruction
@onready var hud_timer: RichTextLabel = $HudTimer
@onready var score_label: RichTextLabel = $Score

var spike_texture: Texture2D = preload("res://assets/spike.svg")
var time_limit: float = 6.0
var round_over: bool = false
var elapsed: float = 0.0
var spawn_cooldown: float = 0.4
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	time_limit = Global.time_limit()
	themed_timer.start(time_limit)
	instruction.text = "DODGE!"
	rng.randomize()


func _process(delta: float) -> void:
	if round_over:
		return
	elapsed += delta
	instruction.visible = elapsed < INSTRUCTION_TIME
	score_label.text = "Score: %d" % Global.score
	hud_timer.text = "%.1f" % maxf(themed_timer.time_left, 0.0)

	_move_player(delta)
	_move_and_check_spikes(delta)

	if themed_timer.time_left <= 0.0:
		_win()


func _move_player(delta: float) -> void:
	var dir := Input.get_axis("ui_left", "ui_right")
	player.position.x = clampf(player.position.x + dir * PLAYER_SPEED * delta, 20.0, 620.0)


func _move_and_check_spikes(delta: float) -> void:
	# spawn
	spawn_cooldown -= delta
	if spawn_cooldown <= 0.0:
		_spawn_spike()
		spawn_cooldown = rng.randf_range(0.55, 0.85) / Global.speed_multiplier

	# move + collide (manual Rect2 intersection, no physics needed)
	var player_rect := Rect2(player.position - PLAYER_HALF, PLAYER_HALF * 2.0)
	for spike in obstacles.get_children():
		spike.position.y += float(spike.get_meta("speed")) * delta
		if spike.position.y > 400.0:
			spike.queue_free()
			continue
		var spike_rect := Rect2(spike.position - SPIKE_SIZE * 0.5, SPIKE_SIZE)
		if spike_rect.intersects(player_rect):
			_fail()
			return


func _spawn_spike() -> void:
	var spike := Sprite2D.new()
	spike.texture = spike_texture
	spike.scale = Vector2(0.5, 0.5)
	spike.position = Vector2(rng.randf_range(24.0, 616.0), -20.0)
	spike.set_meta("speed", rng.randf_range(170.0, 260.0) * Global.speed_multiplier)
	obstacles.add_child(spike)


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
