extends Node3D

@export var paper_code: String = ""

@export var hold_position: Vector3 = Vector3(0, 0, 0)
@export var hold_rotation: Vector3 = Vector3(0, 0, 0)
@export var hold_scale: Vector3 = Vector3(1, 1, 1)

var is_held: bool = false
var holder: Node3D = null

func interact(player: Node3D):
	# Prevent picking multiple items
	if not is_held and player.held_item == null:
		pick_up(player)
	elif is_held:
		try_give_or_throw(player)
	else:
		print("You're already holding something!")
		ThoughtManager.show_thought("I have already holding something")


func pick_up(player: Node3D):
	var hand := player.get_node_or_null("Hand")
	if hand == null:
		push_warning("Player has no Hand node!")
		return

	is_held = true
	holder = player
	player.held_item = self

	# Connect now (so only held paper listens)
	if not EventsManager.custom_event.is_connected(throw_called):
		EventsManager.custom_event.connect(throw_called)

		
	# Attach to hand
	if get_parent():
		get_parent().remove_child(self)
	hand.add_child(self)

	transform = Transform3D.IDENTITY
	translate(hold_position)
	rotation_degrees = hold_rotation
	scale = hold_scale


func try_give_or_throw(player: Node3D):
	var ray := player.get_node_or_null("RayCast3D")
	if ray == null:
		push_warning("Player has no RayCast3D node!")
		return

	if not ray.is_colliding():
		return

	var target = ray.get_collider()

	# NPC
	if target and target.has_method("receive_paper"):
		if target.receive_paper(self):
			cleanup_after_drop()
		else:
			print("NPC refused paper with code:", paper_code)
		return

	# Dustbin
	if target and target.has_method("throw_paper"):
		target.throw_paper(self)
		cleanup_after_drop()
		return


func cleanup_after_drop():
	is_held = false
	if EventsManager.custom_event.is_connected(throw_called):
		EventsManager.custom_event.disconnect(throw_called)
	queue_free()
	
func throw_called(data):
	if data == "throw":
		cleanup_after_drop()

func set_code(code_text):
	paper_code = code_text
	print("Set code:", code_text)
