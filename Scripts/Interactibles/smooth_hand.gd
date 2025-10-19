extends Node3D

var target_basis: Basis

func _process(delta: float):
	# Step 1: Get target rotation (from camera)
	var camera = get_parent()  # Assuming Camera3D is parent
	var desired_basis = camera.global_transform.basis

	# Step 2: Smoothly interpolate towards it
	target_basis = target_basis.slerp(desired_basis, 8.0 * delta)
	global_transform.basis = target_basis
