extends Node2D
## Themed Timer - the guide's "Creating a Themed Timer" step.
## A reusable countdown scene: microgames instance it, call start(seconds),
## then poll time_left or await the timed_out signal. The label shows the
## countdown snapped to a tenth of a second, exactly like the guide's code.

signal timed_out

@onready var timer_label: RichTextLabel = $Timer

var time_left: float = 0.0
var running: bool = false


func _ready() -> void:
	if not running:
		timer_label.text = "0.0"


func start(seconds: float) -> void:
	time_left = maxf(seconds, 0.0)
	running = true


func _process(delta: float) -> void:
	if not running:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		running = false
		timer_label.text = "0.0"
		timed_out.emit()
	else:
		timer_label.text = str(snapped(time_left, 0.1))
