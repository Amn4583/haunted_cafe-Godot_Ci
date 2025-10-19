extends Node3D
signal minigame_finished

func _ready():
	print("Photocopy minigame started")
	EventsManager.custom_event.connect(_on_minigame_done)
	
func _on_minigame_done(data) -> void:
	if data == "finish_minigame":
		emit_signal("minigame_finished")
