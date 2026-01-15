extends Node
# List of all possible tasks
var tasks: Array[String] = ["photocopy", "print", "scan", "laminate"]
# Keep track of queued NPCs + their tasks
var active_tasks: Array = []

func get_random_task() -> String:
	if tasks.is_empty():
		return "photocopy" # fallback if list is empty
	
	# Pick random index from tasks
	return tasks[randi() % tasks.size()]

# Called by NPC when reaching counter
func queue_task(npc, task: String):
	active_tasks.append({ "npc": npc, "task": task })
	print(npc, task)
	print("NPC wants: ", task)
	emit_signal("task_requested", task, self)
	
	# You can trigger UI here (example: show "Press E to photocopy")
	# Example placeholder:
	# get_node("/root/UI").show_task_popup(task, npc)
# Called when an NPC finishes its task
func task_done(npc, task: String):
	active_tasks.append({ "npc": npc, "task": task })
	npc.task_done()
	
