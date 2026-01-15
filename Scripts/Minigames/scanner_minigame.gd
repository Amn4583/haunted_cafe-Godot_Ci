extends Control

@onready var copies_needed_label = $copies_needed
@onready var code_label = $document_code
@onready var print_button = $print_button
@onready var print_minigame = $"../print"
var copies_left = 0
var current_code = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	EventsManager.UI_request.connect(_on_ui_requested)
	print_button.disabled = true

func _on_ui_requested(unique_code, copies_needed):
	print("Computer received.")
	copies_needed_label.text = "Copies Needed: " + str(copies_needed)
	code_label.text = "Document Code: " + unique_code
	print("Computer received Code:", unique_code, " Copies:", copies_needed)
	print_button.disabled = false
	copies_left = copies_needed
	current_code = unique_code
	
	
func _on_print_button_pressed() -> void:
	if copies_left > 0:
		print_minigame._spawn_paper(current_code)
		copies_left = copies_left - 1
		_update_text()

func _update_text():
	copies_needed_label.text = "Copies Needed: " + str(copies_left)
	if copies_left == 0:
		print_button.disabled = true
		current_code = ""
		code_label.text = "Document Code: " + current_code
