extends Node3D
@onready var box = $".."

func _ready() -> void:
	set_meta("interaction_name", "Next tape")
	
func interact(player):
	box.change_track()
