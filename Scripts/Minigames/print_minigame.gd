extends Control

@export var paper_scene: PackedScene
@onready var code_input: LineEdit = $CodeInput
@onready var print_button: Button = $PrintButton
@onready var printer: Node3D = $"../../../../Appliances/printer"
@export var spawn_point: Node3D
@onready var status_label: Label = $StatusLabel

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

	if code_text in valid_codes:
		status_label.text = "Printing..."
		status_label.modulate = Color.YELLOW
		_spawn_paper(code_text)
	else:
		status_label.text = "Invalid code!"
		status_label.modulate = Color.RED


func _spawn_paper(code_text: String):
	var paper = paper_scene.instantiate()

	# Prevent pickup initially
	if paper.has_method("can_pickup"):
		paper.can_pickup()

	# Position paper at printer
	if spawn_point:
		paper.global_position = spawn_point.global_position
		paper.global_rotation = spawn_point.global_rotation
	else:
		paper.position = Vector3(0.0, -1.172, -0.932)
		paper.rotation = Vector3(-11.0, 0.0, 0.0)

	printer.add_child(paper)

	# Set code on paper
	if paper.has_method("set_code"):
		paper.set_code(code_text)

	# ▶️ Play its animation and sound
	var anim_player: AnimationPlayer = paper.get_node_or_null("AnimationPlayer")
	var sound: AudioStreamPlayer3D = paper.get_node_or_null("AudioStreamPlayer3D")

	if anim_player:
		anim_player.play("output")

	if sound:
		sound.play()

	# Wait for animation end before making it pickable
	if anim_player:
		var duration = anim_player.get_animation("output").length
		await get_tree().create_timer(duration).timeout

	# Enable pickup
	if paper.has_method("can_pickup"):
		paper.can_pickup()
	status_label.text = "Printed successfully!"
	status_label.modulate = Color.GREEN
	print("Printed paper with code:", code_text)
