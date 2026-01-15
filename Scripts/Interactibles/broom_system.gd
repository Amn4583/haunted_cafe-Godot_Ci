extends  CharacterBody3D

@onready var collision = $CollisionShape3D
@onready var dust_particles = $GPUParticles3D
var last_pos : Vector3

func _ready() -> void:
	last_pos = global_transform.origin
	collision.disabled = true
	EventsManager.custom_event.connect(_on_collided)

func _process(delta):
	var current_pos = global_transform.origin
	var speed = (current_pos - last_pos).length() / delta
	
	if speed > 0.1: # broom is moving
		dust_particles.emitting = true
	else:
		dust_particles.emitting = false
	
	last_pos = current_pos

func _on_collided(data):
	if data == "broom_picked":
		collision.disabled = false
	if data == "broom_placed":
		collision.disabled = true
