# npc.gd
extends CharacterBody3D

signal task_requested(task: String, npc: Node)
signal npc_finished
signal minigame_finished

signal photocopy_request(unique_code, copies_needed)

@export var speed: float = 1.0
@export var rotation_speed: float = 5.0
@export var stop_distance: float = 0.5
@onready var look_at_mod = $Skeleton3D/LookAtModifier3D
var player: Node3D = null

# Optional inspector defaults (spawner will usually override via assign_task)
@export var counter: Node3D
@export var exit_point: Node3D
#Paper System
@export var npc_name: String

@export var unique_code: String
var copies_needed = 2
var received_paper: Node3D = null

# Navigation + animation
var nav_agent: NavigationAgent3D
var anim_tree: AnimationTree
var state_machine

# runtime state
var target: Node3D = null
var task: String = ""
var waiting_for_task: bool = false
var talk_state = true

var closing_dialogue = false
@onready var dialogue_balloon = preload("res://Dialogues/Styles/balloon.tscn")

func interact(player):
	if talk_state:
		play_dialogue("res://Dialogues/Day1-npc1.dialogue")
		EventsManager.emit_custom_event("is_talking")
		talk_state = false
		set_meta("interaction_name", "Give")
		request_photocopy()
		
	else:
		if player.held_item == null:
			print("You have nothing to give me!" % npc_name)
			ThoughtManager.show_thought("[b][color=FFA500]Customer: [/color][/b]I want Addhar Card form.")
			return
			
		var item = player.held_item
		if item.has_method("set_code"): # Optional check, but not needed usually
			print("Hmm, what’s this paper?")
			
		if receive_paper(item):
			print("%s: Thanks for the paper!" % npc_name)
		else:
			print("%s: I can’t accept this paper." % npc_name)
			ThoughtManager.show_thought("")
				
func receive_paper(paper: Node3D) -> bool:
	# You can check conditions — for example, paper code or type
	if paper.paper_code == unique_code and paper.is_printed == true:
		received_paper = paper
		# Optional: trigger animation or sound
		print("%s received paper with code: %s" % [npc_name, paper.paper_code])
		paper.cleanup_after_drop() # The paper frees itself safely
		closing_dialogue = true
		EventsManager.emit_custom_event("is_talking")
		play_dialogue("res://Dialogues/Day1-npc1_closing.dialogue")
		set_collision_layer_value(5, 0)
		return true
		
	else:
		print("%s rejected paper with code: %s" % [npc_name, paper.paper_code])
		return false
		
func play_dialogue(dialogue_path: String):
	var dialogue_resource = load(dialogue_path)
	if dialogue_resource:
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon, dialogue_resource, "start")

func on_dialogue_ended(resource: DialogueResource):
	if closing_dialogue:
		EventsManager.emit_custom_event("finish_minigame")
		EventsManager.emit_custom_event("is_ended")
	else:
		EventsManager.emit_custom_event("is_ended")
		set_collision_layer_value(5, 1)

func request_photocopy():
	EventsManager.emit_photocopy_request(unique_code, copies_needed)
func _ready():
	set_meta("interaction_name", "Talk")
	DialogueManager.dialogue_ended.connect(on_dialogue_ended)
	
	randomize()
	# nav agent node (must exist in the NPC scene)
	nav_agent = $NavigationAgent3D
	nav_agent.path_desired_distance = 0.5
	nav_agent.target_desired_distance = stop_distance
	nav_agent.avoidance_enabled = true

	# optional animation tree (only if your NPC scene has one)
	if has_node("AnimationTree"):
		anim_tree = $AnimationTree
		if anim_tree:
			anim_tree.active = true
			# Playback state machine path commonly is "parameters/playback"
			# If your tree is different, set this accordingly.
			state_machine = anim_tree["parameters/playback"]

	# If spawner/editor provided counter via export and target not set yet, use it
	if target == null and counter:
		target = counter
		if nav_agent:
			nav_agent.target_position = target.global_transform.origin

# Call this from your NPCSpawner immediately AFTER add_child(npc) and after setting npc position.
# Example in spawner:
#   add_child(npc)
#   npc.global_transform.origin = spawn_point.global_transform.origin
#   npc.assign_task(task_name, counter_node, exit_node)
func assign_task(t: String, counter_point: Node3D, exit_p: Node3D, start_moving := true) -> void:
	task = t if t != null else ""
	# prefer provided nodes; fallback to exported ones if provided in inspector
	if counter_point:
		counter = counter_point
	if exit_p:
		exit_point = exit_p
	target = counter
	waiting_for_task = false
	if nav_agent and target:
		nav_agent.target_position = target.global_transform.origin
	# optionally switch to walking animation
	if start_moving:
		_set_walking()

func _physics_process(delta):
	if target == null:
		return

	# keep nav agent targeting updated (in case target moves)
	nav_agent.target_position = target.global_transform.origin

	# if agent reports finished (reached)
	if nav_agent.is_navigation_finished():
		velocity = Vector3.ZERO
		move_and_slide()

		# reached counter and hasn't requested task yet
		if target == counter and not waiting_for_task:
			set_collision_layer_value(5, 1)
			waiting_for_task = true
			_set_idle()
			print(name, " reached counter, requesting task:", task)
			emit_signal("task_requested", task, self)
			return

		# reached exit → done
		if target == exit_point:
			print(name, " reached exit, finished.")
			emit_signal("npc_finished")
			queue_free()
			return

		# otherwise do nothing while standing
		return

	# movement toward next path point
	var next_point: Vector3 = nav_agent.get_next_path_position()
	var direction: Vector3 = (next_point - global_transform.origin).normalized()

	# apply exported speed so inspector changes take effect
	velocity = direction * speed
	move_and_slide()

	# animation control (safe checks)
	if velocity.length() > 0.1:
		_set_walking()
	else:
		_set_idle()

	# rotation smoothing
	if direction.length() > 0.1:
		var target_rot := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_rot, rotation_speed * delta)

# Called by DayManager/TaskManager when the player finishes the NPC's minigame
func complete_task() -> void:
	if not waiting_for_task:
		return
	waiting_for_task = false
	task = ""
	if exit_point:
		target = exit_point
		if nav_agent:
			nav_agent.target_position = target.global_transform.origin
		_set_walking()

# Helpers for animation safe-travel
func _set_idle():
	if state_machine != null:
		# guard so missing animation tree won't crash
		if typeof(state_machine) != TYPE_NIL:
			if state_machine.get_current_node() != "idle":
				state_machine.travel("idle")

func _set_walking():
	if state_machine != null:
		if typeof(state_machine) != TYPE_NIL:
			if state_machine.get_current_node() != "walking":
				state_machine.travel("walking")

func set_player_node(p: Node) -> void:
	if not is_instance_valid(p):
		push_warning("set_player_node: provided player is invalid or freed")
		return
	player = p
	if look_at_mod:
		# LookAtModifier3D.target_node expects a NodePath — use get_path()
		look_at_mod.target_node = player.get_path()
		look_at_mod.active = true
