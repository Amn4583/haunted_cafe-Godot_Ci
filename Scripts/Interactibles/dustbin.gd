extends Node3D

func _ready() -> void:
	set_meta("interaction_name", "Dustbin")

func interact(player):
	if player.held_item == null:
		print("You're not holding anything")
		ThoughtManager.show_thought("I have nothing to throw away")
		return

	if player.held_item != null:
		EventsManager.emit_custom_event("throw")
