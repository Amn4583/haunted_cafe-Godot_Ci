extends CharacterBody3D


const SPEED = 1.2
const JUMP_VELOCITY = 4.5
const sensitivity = 0.2
@export var joystick: VirtualJoystick
@onready var footstep_player = $"Walking sound"
@export var movement_threshold: float = 0.1
var held_item: Node3D = null
var input_dir
#-----------------------------------------------

#Camera
@onready var camera = $Camera3D
@onready var raycast = $head/Camera3D/pick_up_ray

@export var normal_fov: float = 60.0
@export var inspect_fov: float = 40.0
@export var transition_speed: float = 3.0
#--------------------------------------------------

var can_control := false
var is_inspecting: bool = false
var was_moving: bool = false
var bob_time = 0.0
var is_colliding_with_target: bool = false
var rotation_allowed = true
func _ready():
	EventsManager.custom_event.connect(on_pc)
func _physics_process(delta: float) -> void:
	if can_control:
		pass
	if camera:
		var target_fov = inspect_fov if is_inspecting else normal_fov
		camera.fov = lerpf(camera.fov, target_fov, delta * transition_speed)
		
	if rotation_allowed:
		# Add the gravity.
		if not is_on_floor():
			velocity += get_gravity() * delta
			
		# Handle jump.
		if Input.is_action_just_pressed("ui_accept") and is_on_floor():
			velocity.y = JUMP_VELOCITY
		if joystick:
			input_dir = joystick.output
		else:
			input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			velocity.z = move_toward(velocity.z, 0, SPEED)
		move_and_slide()
	
	#Footsteps
	var is_moving = velocity.length() > movement_threshold
	# Optional: Add && is_on_floor() if you only want footsteps when grounded
	if is_moving && is_on_floor():
		if not footstep_player.playing:
			footstep_player.volume_db = -30.0
			footstep_player.play()
	else:
		if footstep_player.playing:
			footstep_player.stop()


func _input(event):
	if rotation_allowed:
		if event is InputEventScreenDrag:
			if event.position.x >= get_viewport().size.x/4:
				$Camera3D.rotate_x(-deg_to_rad(event.relative.y * sensitivity))
				rotate_y(-deg_to_rad(event.relative.x * sensitivity))
				$Camera3D.rotation.x = clamp($Camera3D.rotation.x, deg_to_rad(-80), deg_to_rad(80))
			
	if event.is_action_pressed("zoom"):
		is_inspecting = true
	
	if event.is_action_released("zoom"):
		is_inspecting = false


func _on_talking(data):
	if data == "is_talking":
		is_inspecting = true

func _on_ended(data):
	if data == "is_ended":
		is_inspecting = false
		
func on_pc(data):
	if data == "using_pc":
		$Crosshair.visible = false
		rotation_allowed = false
	if data == "exit_pc":
		rotation_allowed = true
		$Crosshair.visible = true
	if data == "is_ended":
		$Crosshair.visible = true
		rotation_allowed = true
		is_inspecting = false
	if data == "is_talking":
		$Crosshair.visible = false
		rotation_allowed = false
		is_inspecting = true

		
