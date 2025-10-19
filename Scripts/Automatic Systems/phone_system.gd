extends StaticBody3D

@onready var dialogue_balloon = preload("res://Dialogues/Styles/balloon.tscn")

func _ready() -> void:
	set_meta("interaction_name", "Phone")
	DialogueManager.dialogue_ended.connect(on_phone_ended)
	
func interact(player):
	play_dialogue("res://Dialogues/Phone_call.dialogue")
	EventsManager.emit_custom_event("is_talking")


func play_dialogue(dialogue_path: String):
	var dialogue_resource = load(dialogue_path)
	if dialogue_resource:
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon, dialogue_resource, "start")

func on_phone_ended(resource: DialogueResource):
	EventsManager.emit_custom_event("is_ended")
	queue_free()
