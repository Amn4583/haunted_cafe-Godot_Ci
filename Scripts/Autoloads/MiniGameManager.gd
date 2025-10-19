extends Node

signal task_completed(npc: Node)

# Map task names to minigame scene files
@export var task_scenes := {
	"photocopy": preload("res://Scenes/Minigames/laminate.tscn"),
	"print": preload("res://Scenes/Minigames/laminate.tscn"),
	"scan": preload("res://Scenes/Minigames/laminate.tscn"),
	"laminate": preload("res://Scenes/Minigames/laminate.tscn")
	}

var current_task_scene: Node = null
var current_npc: Node = null

# Called by DayManager when NPC asks for a task
func start_task(task: String, npc: Node):
	if not task_scenes.has(task):
		push_error("⚠️ Unknown task: " + str(task))
		return

	# Store the npc that needs this task
	current_npc = npc

	# Instance the right minigame
	var scene = task_scenes[task].instantiate()
	add_child(scene)
	current_task_scene = scene

	# Connect the minigame's "minigame_finished" signal
	if current_task_scene.has_signal("minigame_finished"):
		current_task_scene.minigame_finished.connect(_on_minigame_finished)
	else:
		push_error("⚠️ Minigame scene missing 'minigame_finished' signal!")

	print("🎮 Started minigame: ", task)

func _on_minigame_finished():
	print("✅ Minigame finished for NPC")

	# Clean up the minigame scene
	if current_task_scene:
		current_task_scene.queue_free()
		current_task_scene = null

	# Tell the NPC to leave
	if current_npc:
		current_npc.complete_task()
		emit_signal("npc_finished", current_npc)
		current_npc = null
