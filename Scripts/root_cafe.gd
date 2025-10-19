extends  Node3D

@export var label: Label
@onready var joystick = $Control/VirtualJoystick
@onready var Gui = $Control/Inspection
func _ready() -> void:
	ThoughtManager.set_thought_label(label)
	EventsManager.custom_event.connect(on_custom_event)

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
