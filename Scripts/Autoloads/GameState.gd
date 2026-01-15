extends Node

# Variables to track story progress
var current_day: int = 1
var current_task: String = ""
var npc_interactions := {}
var special_events_triggered := {}

signal task_changed(new_task)
signal event_triggered(event_name)

func set_task(task_name: String):
	var translated_task = tr(task_name)
	current_task = translated_task
	emit_signal("task_changed", translated_task)
	print("[GameState] Task changed:", translated_task)

func mark_npc_interacted(npc_name: String):
	npc_interactions[npc_name] = true
	print("[GameState] Interacted with:", npc_name)
	_check_for_special_triggers()

func trigger_event(event_name: String):
	if event_name in special_events_triggered:
		return # prevent repeating events
	special_events_triggered[event_name] = true
	emit_signal("event_triggered", event_name)
	print("[GameState] Special event triggered:", event_name)

func _check_for_special_triggers():
	# Example condition
	if current_day == 2 and "NPC_2" in npc_interactions and not "jumpscare_day2" in special_events_triggered:
		trigger_event("jumpscare_day2")
