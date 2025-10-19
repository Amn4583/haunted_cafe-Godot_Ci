extends Node

@export var dust_scene: PackedScene
@export var spawn_area: Node3D  # use a big Area3D or reference to floor
@export var dust_count_per_day: int = 10

func _ready():
	for i in range(dust_count_per_day):
		var dust = dust_scene.instantiate()
		add_child(dust)

		var rand_x = randf_range(-5, 5)
		var rand_z = randf_range(-5, 5)
		dust.global_position = spawn_area.global_position + Vector3(rand_x, 0, rand_z)
