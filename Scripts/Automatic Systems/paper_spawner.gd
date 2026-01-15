extends Node3D

@export var paper_scene: PackedScene
@export var npc: PackedScene

func _ready():
	# Connect to the NPC request signal (set this via script or inspector)
	EventsManager.photocopy_request.connect(_on_photocopy_request)

func _on_photocopy_request(unique_code, copies_needed):
	var paper = paper_scene.instantiate()
	add_child(paper)
	
	paper.set_code(unique_code, copies_needed)
	paper.is_printed = false
	
	# Optionally position it
