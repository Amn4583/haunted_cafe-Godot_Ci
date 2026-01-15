extends Node3D

var code: String = ""
var copies: int = 0

func _ready() -> void:
	set_meta("interaction_name", "Scan")
	EventsManager.scan_request.connect(_on_scan_requested)
	
func interact(player):
	if player.held_item == null:
		print("You have nothing to scan.")
		return
	var item = player.held_item
	receive_paper(item)
	
func receive_paper(paper: Node3D):
	paper.cleanup_after_drop()

func _on_scan_requested(unique_code, copies_needed):
	code = unique_code
	copies = copies_needed
	print("Scanned paper with ", "Code:", code, " Copies:", copies)
	await get_tree().create_timer(3.0).timeout
	request_computer(code, copies)
	
func request_computer(unique_code, copies_needed):
	EventsManager.emit_UI_request(unique_code, copies_needed)
	code = ""
	copies = 0
	print("Code cleaned to: ", code, copies)
	
