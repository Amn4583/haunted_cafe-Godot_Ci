extends Node3D

# Drag all possible NPC scenes here
@export var npc_scenes: Array[PackedScene] = []

# Drag these from your scene (empty Position3D / Marker3D nodes)
@export var spawn_point: Node3D
@export var counter_point: Node3D
@export var exit_point: Node3D
@export var player: Node3D

var npc_count := 0

func spawn_npc(task: String):
	print("Spawned Random NPC")
	if npc_scenes.is_empty():
		push_error("No NPC scenes assigned in NPCSpawner!")
		return
	
	# Pick random NPC scene
	var npc_scene: PackedScene = npc_scenes[randi() % npc_scenes.size()]
	var npc = npc_scene.instantiate()
	add_child(npc)

	# Place NPC at the spawn location
	npc.global_transform.origin = spawn_point.global_transform.origin
	npc.assign_task(task, counter_point, exit_point)
	
	# ✅ Assign targets so NPC script has them
	npc.counter = counter_point
	npc.exit_point = exit_point
	npc.task = task

	npc_count += 1
	return npc

func spawn_specific_npc(npc_scene: PackedScene, task: String) -> Node:
	print("Spawned Story NPC")
	var npc = npc_scene.instantiate()
	add_child(npc)

	npc.global_position = spawn_point.global_position
	npc.assign_task(task, counter_point, exit_point)
	npc.set_player_node(player)

	return npc
