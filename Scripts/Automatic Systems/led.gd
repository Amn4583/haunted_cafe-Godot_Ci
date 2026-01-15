extends AnimatedSprite3D

@export var animation_name := "default"
@export var cycle_speed_min := 0.1
@export var cycle_speed_max := 0.3

var next_change_time := 0.0
var total_frames := 0

func _ready():
	randomize()

	animation = animation_name
	stop()  # IMPORTANT: disable built-in animation so it doesn't override frames

	total_frames = sprite_frames.get_frame_count(animation_name)

	next_change_time = randf_range(cycle_speed_min, cycle_speed_max)

func _process(delta):
	next_change_time -= delta

	if next_change_time <= 0.0:
		frame = randi_range(1, total_frames - 1)  # fully random color
		next_change_time = randf_range(cycle_speed_min, cycle_speed_max)
