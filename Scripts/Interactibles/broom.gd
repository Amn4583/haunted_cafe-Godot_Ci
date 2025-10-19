extends Node3D

signal broom_picked
signal broom_placed
var is_held = false
var original_parent: Node = null
@export var store_room: StaticBody3D

func _ready() -> void:
	set_meta("interaction_name", "Grab")

func interact(player):
	if not is_held:
		pick_up(player)

	else:
		put_back()

func pick_up(player):
	EventsManager.emit_custom_event("broom_picked")
	is_held = true
	self.visible = false
	print("🧹 Broom picked up")
	set_meta("interaction_name", "Drop")

func put_back():
	EventsManager.emit_custom_event("broom_placed")
	is_held = false
	self.visible = true
	set_meta("interaction_name", "Grab")
	print("🧹 Broom placed back")
