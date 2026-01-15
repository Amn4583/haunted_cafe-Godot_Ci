extends SpotLight3D

@export var follow_speed: float = 5.0   # How fast the torch follows target
@export var fluctuation_strength: float = 0.02  # Max random offset
@export var flicker_intensity: float = 0.1      # Light energy flicker amount

var target_basis: Basis
var rng := RandomNumberGenerator.new()

func _ready():
	rng.randomize()
	# Start with the same rotation as parent (camera)
	target_basis = global_transform.basis

func _process(delta: float):
	# Step 1: Get target rotation (from camera)
	var camera = get_parent()  # Assuming Camera3D is parent
	var desired_basis = camera.global_transform.basis

	# Step 2: Smoothly interpolate towards it
	target_basis = target_basis.slerp(desired_basis, follow_speed * delta)
	global_transform.basis = target_basis

	# Step 3: Add tiny random fluctuation to make it "shaky"
	var random_offset = Vector3(
		rng.randf_range(-fluctuation_strength, fluctuation_strength),
		rng.randf_range(-fluctuation_strength, fluctuation_strength),
		rng.randf_range(-fluctuation_strength, fluctuation_strength)
	)
	rotate_object_local(Vector3(1,0,0), random_offset.x)
	rotate_object_local(Vector3(0,1,0), random_offset.y)

	# Step 4: Flicker the intensity a bit (optional)
	light_energy = 0.1 + rng.randf_range(-flicker_intensity, flicker_intensity)
