extends StaticBody3D


@onready var snd_open = $open_snd
@onready var snd_close = $close_snd
@onready var snd_lock = $lock_snd

@export var is_locked: bool = false
@export var open_rotation: Vector3 = Vector3(0, 0, 0) # rotation when opened
@export var closed_rotation: Vector3 = Vector3(0, 90, 0) # rotation when closed
@export var locked_rotation: Vector3 = Vector3(0, 0, 0)
@export var open_speed: float = 6.0

var is_open: bool = false
var target_rot: Vector3

func _ready():
	target_rot = closed_rotation
	set_meta("interaction_name", "INT_UNSEAL")

func _process(delta):
	# Smoothly interpolate rotation
	rotation_degrees = rotation_degrees.lerp(target_rot, delta * open_speed)

func interact(player):
	if is_locked:
		print("Door is locked")
		ThoughtManager.show_thought("[b][color=FFA500]Me: [/color][/b]The door is locked.")
		if snd_lock: snd_lock.play()
		await get_tree().create_timer(0.02).timeout
		rotation_degrees = rotation_degrees.lerp(locked_rotation, 1)
		await get_tree().create_timer(0.04).timeout
		rotation_degrees = rotation_degrees.lerp(closed_rotation, 1)
		await get_tree().create_timer(0.15).timeout
		rotation_degrees = rotation_degrees.lerp(locked_rotation, 1)
		await get_tree().create_timer(0.20).timeout
		rotation_degrees = rotation_degrees.lerp(closed_rotation, 1)
		return

	if is_open:
		close_door()
	else:
		open_door()

func open_door():
	is_open = true
	target_rot = open_rotation
	if snd_open: snd_open.play(0.34)
	print("Door opened")
	set_meta("interaction_name", "INT_SEAL")

func close_door():
	is_open = false
	target_rot = closed_rotation
	await get_tree().create_timer(1.5).timeout
	if snd_close: snd_close.play()
	print("Door closed")
	set_meta("interaction_name", "INT_UNSEAL")

func lock():
	is_locked = true
	print("Door locked")

func unlock():
	is_locked = false
	print("Door unlocked")
