extends Node

@export var npc_spawner: Node   # Drag NPCSpawner here
@export var task_manager: Node  # Drag TaskManager here
@export var minigame_manager: Node  # Drag MiniGameManager here

@export var story_mode: bool = true
var current_npc_index = 0
var current_day: int = 1
var npcs_spawned: int = 0
var max_npcs: int = 0
var active_npc: Node = null

#Story Sequence:
var story_days = {
	1: [ # Day 1
		{ "npc_scene": preload("res://Scenes/Npc.tscn"), "task": "photocopy" },
		{ "npc_scene": preload("res://Scenes/Npc.tscn"), "task": "print" }
	],
	2: [ # Day 2
		{ "npc_scene": preload("res://Scenes/Npc.tscn"), "task": "fax" },
		{ "npc_scene": preload("res://Scenes/Npc.tscn"), "task": "scan" },
		{ "npc_scene": preload("res://Scenes/Npc.tscn"), "task": "photocopy" }
	],
	3: [ # Day 3
		{ "npc_scene": preload("res://Scenes/Npc.tscn"), "task": "internet" }
	]
}

func _ready() -> void:
	randomize()
	start_day(1)

func start_day(day: int):
	current_day = day
	current_npc_index = 0
	npcs_spawned = 0
	max_npcs = randi_range(5, 7)
	if story_mode:
		_spawn_story_npc()
		print("Started Story Day ", current_day )
	else:
		print("📅 Day ", current_day, " started with ", max_npcs, " NPCs")
		_spawn_next_npc()

func _spawn_story_npc():
	var day_data = story_days.get(current_day, [])
	if current_npc_index >= day_data.size():
		print("✅ Day ", current_day, " finished")
		_on_day_finished()
		return

	var entry = day_data[current_npc_index]
	var npc = npc_spawner.spawn_specific_npc(entry["npc_scene"], entry["task"])

	if npc:
		active_npc = npc
		npc.task_requested.connect(_on_npc_task_requested)
		npc.npc_finished.connect(_on_npc_finished)

	current_npc_index += 1


func _spawn_next_npc():
	if npcs_spawned >= max_npcs:
		print("✅ Day ", current_day, " finished")
		await get_tree().create_timer(5.0).timeout
		start_day(current_day + 1)
		return

	var task = task_manager.get_random_task()
	active_npc = npc_spawner.spawn_npc(task)
	
	if active_npc:
		active_npc.task_requested.connect(_on_npc_task_requested)
		active_npc.npc_finished.connect(_on_npc_finished)
		
	npcs_spawned += 1

func _on_npc_task_requested(task: String, npc: Node):
	print("📝 NPC requests task: ", task)
	if minigame_manager:
		minigame_manager.start_task(task, npc)

func _on_npc_finished():
	if story_mode:
		print("👋 Story NPC left the shop")
		active_npc = null
		await get_tree().create_timer(randf_range(3, 6)).timeout
		_spawn_story_npc()
	else:
		print("👋 Random NPC left the shop")
		active_npc = null
		await get_tree().create_timer(randf_range(3, 6)).timeout
		_spawn_next_npc()

func _on_day_finished():
	current_day += 1
	if current_day > story_days.size():
		print("🎉 Story finished!")
	else:
		start_day(current_day)
		print("Started Story Day ", current_day)
