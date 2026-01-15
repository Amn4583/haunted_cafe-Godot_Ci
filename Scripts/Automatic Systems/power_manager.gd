extends Node3D

@export var min_time : float = 10.0
@export var max_time : float = 30.0
@export var short_circuit_snd: AudioStreamPlayer3D
@export var restore_snd: AudioStreamPlayer3D
@onready var short_anim = $short_anim
@export var green_light: MeshInstance3D
@export var red_light: MeshInstance3D
@export var main_lights: MeshInstance3D
@onready var light_map = $"../LightmapGI"
@onready var lightmap_path = preload("res://Scenes/Lightmap/cafe.lmbake")
var lights_off : bool = false

func _ready():
	randomize()
	_schedule_power_cut()
	set_meta("interaction_name", "Power is active")

func interact(player):
	if not lights_off:
		return
	else:
		_restore_power()

func _schedule_power_cut():
	var wait_time = randf_range(min_time, max_time)
	await get_tree().create_timer(wait_time).timeout
	_cut_power()

func _cut_power():
	lights_off = true
	var lights = get_tree().get_nodes_in_group("power_lights")
	for l in lights:
		if l is Node3D:
			l.visible = false
			short_anim.play("short")
			light_map.light_data = null
			if short_circuit_snd:
				short_circuit_snd.play()
	print("Power cut! Find the inverter.")
	set_meta("interaction_name", "Reactivate Power")

func _restore_power():
	lights_off = false
	var lights = get_tree().get_nodes_in_group("power_lights")
	for l in lights:
		if l is Node3D:
			l.visible = true
			short_anim.play("restore")
			restore_snd.play()
			light_map.light_data = lightmap_path
	print("Power restored!")
	_schedule_power_cut()  # schedule next random outage
	set_meta("interaction_name", "Power is active")

func set_emission(mesh: MeshInstance3D, enabled: bool):
	var mat := mesh.material_override
	
	# If material_override is empty, create it from the surface material
	if mat == null:
		mat = mesh.get_active_material(0)
		if mat == null:
			print("No material on mesh!")
			return

		mat = mat.duplicate() # unique instance
		mesh.material_override = mat

	# Toggle emission
	mat.emission_enabled = enabled

	if enabled:
		mat.emission_energy = 1.3
	else:
		mat.emission_energy = 0.0
