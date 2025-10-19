extends Node3D

@export var min_time : float = 10.0
@export var max_time : float = 30.0

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
			$"../Sounds/short_circuit".play()
	print("⚡ Power cut! Find the inverter.")
	set_meta("interaction_name", "Reactivate Power")

func _restore_power():
	lights_off = false
	var lights = get_tree().get_nodes_in_group("power_lights")
	for l in lights:
		if l is Node3D:
			l.visible = true
	print("🔋 Power restored!")
	_schedule_power_cut()  # schedule next random outage
	set_meta("interaction_name", "Power is active")
