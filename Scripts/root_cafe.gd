extends  Node3D

@onready var label = $Control/Label
@onready var label_bg = $Control/Label_bg
@onready var Gui = $Control/Inspection
@onready var fps_label = $Control/fps_label
@onready var task_label = $Control/TaskLabel
@onready var fade = $Control/Animations/Fade
@onready var joystick = $Control/VirtualJoystick
func _ready() -> void:
	ThoughtManager.set_thought_nodes(label, label_bg)
	EventsManager.custom_event.connect(on_custom_event)
	TranslationServer.set_locale("en")
	start_story()
	
func _process(delta: float) -> void:
	fps_label.text = "FPS: " + str(Engine.get_frames_per_second())

func start_story():
	# Story sequence 
	fade.play("fade_out")
	await fade.animation_finished
	ThoughtManager.show_thought("THOUGHT_1")
	await get_tree().create_timer(6.0).timeout
	ThoughtManager.show_thought("THOUGHT_2")
	await get_tree().create_timer(10.0).timeout
	GameState.set_task("TASK_1")
	
func on_custom_event(data):
	if data == "is_talking" or data == "using_pc":
		joystick.visible = false
		joystick.process_mode = Node.PROCESS_MODE_DISABLED
		Gui.visible = false
		Gui.process_mode = Node.PROCESS_MODE_DISABLED
		
	if data == "is_ended" or data == "exit_pc":
		joystick.visible = true
		joystick.process_mode = Node.PROCESS_MODE_ALWAYS
		Gui.visible = true
		Gui.process_mode = Node.PROCESS_MODE_ALWAYS
