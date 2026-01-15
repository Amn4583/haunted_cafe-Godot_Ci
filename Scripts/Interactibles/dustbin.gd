extends Node3D

func _ready() -> void:
	set_meta("interaction_name", "INT_DUSTBIN")

func interact(player):
	if player.held_item == null:
		print("You're not holding anything")
		ThoughtManager.show_thought("THOUGHT_5")
		return

	if player.held_item != null:
		EventsManager.emit_custom_event("throw")
