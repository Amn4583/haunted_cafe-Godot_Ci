extends Camera3D

var bob_time: float = 0.0
var breath_time: float = 0.0
var default_cam_pos: Vector3
var rng := RandomNumberGenerator.new()
@onready var broom = $"../broom_and_buscket_grp"
@onready var broom_main = get_node("Cafe/Assets/broom_and_buscket_grp")
@onready var crosshair_label = $"../Crosshair/interact_data"
# Walking bob
@export var bob_speed: float = 6.0
@export var bob_intensity: float = 0.05
@export var sway_intensity: float = 0.03
@export var tilt_intensity: float = 0.04
@export var noise_intensity: float = 0.01

# Breathing
@export var breath_speed: float = 1.5
@export var breath_intensity: float = 0.02
@export var breath_sway: float = 0.01
@onready var flashlight_snd = $flashlight
var flashlight = false
var player

var held_item: Node3D = null

func _ready():
	EventsManager.custom_event.connect(_on_broom_picked)
	broom.visible = false
	default_cam_pos = position
	rng.randomize()
	player = get_parent()  # assumes Camera is direct child of Player
	
func _process(delta: float) -> void:
	var ray = $pick_up_ray
	if ray.is_colliding():
		var cross = ray.get_collider()
		if cross.has_method("interact") or cross.has_method("throw_paper"):
			$"../Crosshair/dynamic_cross".visible = true
			
		if cross.has_meta("interaction_name"):
			crosshair_label.text = str(cross.get_meta("interaction_name"))
		else:
			crosshair_label.text = ""
	else:
		$"../Crosshair/dynamic_cross".visible = false
		crosshair_label.text = ""
			
func _physics_process(delta):
	if player == null:
		return

	var velocity: Vector3 = player.velocity
	var input_dir: Vector3 = Vector3(player.input_dir.x, 0, player.input_dir.y)

	var was_moving: bool = player.is_on_floor() and (velocity.x != 0 or velocity.z != 0)

	if was_moving:
		var move_speed = velocity.length()
		var intensity = clamp(move_speed / 5.0, 0.5, 1.5)
		bob_time += delta * bob_speed * intensity

		var bob_y = sin(bob_time) * bob_intensity * intensity
		var bob_x = sin(bob_time * 0.5) * sway_intensity * intensity
		var noise = (rng.randf() - 0.5) * noise_intensity

		position.y = lerp(position.y, default_cam_pos.y + bob_y + noise, 8.0 * delta)
		position.x = lerp(position.x, default_cam_pos.x + bob_x, 8.0 * delta)

		var tilt = -input_dir.x * tilt_intensity * intensity
		rotation.z = lerp(rotation.z, tilt, 5.0 * delta)

	else:
		breath_time += delta * breath_speed
		var breath_y = sin(breath_time) * breath_intensity
		var breath_x = sin(breath_time * 0.5) * breath_sway
		var noise = (rng.randf() - 0.5) * noise_intensity * 0.5

		position.y = lerp(position.y, default_cam_pos.y + breath_y + noise, 3.0 * delta)
		position.x = lerp(position.x, default_cam_pos.x + breath_x, 3.0 * delta)
		rotation.z = lerp(rotation.z, 0.0, 4.0 * delta)

		bob_time += delta * bob_speed * 0.5
		
func _input(event):
	if event.is_action_pressed("interact"):
		var ray = $pick_up_ray
		if ray.is_colliding():
			var obj = ray.get_collider()
			if obj.has_method("interact"):
				obj.interact(self)
				
	if event.is_action_pressed("flashlight"):
		if flashlight:
			$SpotLight3D.visible = false
			flashlight = false
			flashlight_snd.play()
			print("Flashlight turned off")
		else:
			$SpotLight3D.visible = true
			flashlight = true
			flashlight_snd.play()
			print("Flashlight turned on")
			
		
				
func _on_broom_picked(data):
	if data == "broom_picked":
		broom.visible = true
	if data == "broom_placed":
		broom.visible = false
