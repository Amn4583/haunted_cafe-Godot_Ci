extends Control

@export var paper_scene: PackedScene
@onready var code_input: LineEdit = $CodeInput
@onready var print_button: Button = $PrintButton
@onready var printer: Node3D = $"../../../../Appliances/printer"
@export var spawn_point: Node3D
@onready var status_label: Label = $StatusLabel #Add a Label node in your scene called "StatusLabel"

# ✅ Predefined valid codes
var valid_codes: Array = ["A1B2C3", "SECRET42", "TEST123", "DEVIL999"]

func _ready():
	print_button.pressed.connect(_on_print_pressed)

func _on_print_pressed():
	var code_text = code_input.text.strip_edges()

	if code_text == "":
		status_label.text = "Enter a code first!"
		status_label.modulate = Color.RED
		return

	# Check if code is valid
	if code_text in valid_codes:
		_spawn_paper(code_text)
		status_label.text = "Printed successfully!"
		status_label.modulate = Color.GREEN
	else:
		status_label.text = "Invalid code!"
		status_label.modulate = Color.RED

func _spawn_paper(code_text: String):
	# Spawn paper
	var paper = paper_scene.instantiate()

	# Use spawn_point position if available
	if spawn_point:
		paper.global_position = spawn_point.global_position
		paper.global_rotation = spawn_point.global_rotation
	else:
		paper.position = Vector3(0.0, -1.172, -0.932)
		paper.rotation = Vector3(-11.0, 0.0, 0.0)

	printer.add_child(paper)

	# Send code to paper
	if paper.has_method("set_code"):
		paper.set_code(code_text)

	print("Printed paper with code:", code_text)
