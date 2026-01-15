extends StaticBody3D

@onready var dialogue_balloon = preload("res://Dialogues/Styles/balloon.tscn")
@onready var ringtone = $ringtone_snd
func _ready() -> void:
	set_meta("interaction_name", "INT_PHONE")
	DialogueManager.dialogue_ended.connect(on_phone_ended)
	set_collision_layer_value(5, 0)
	await get_tree().create_timer(16.5).timeout
	set_collision_layer_value(5, 1)
	ringtone.play()
	
func interact(player):
	play_dialogue("res://Dialogues/Phone_call.dialogue")
	EventsManager.emit_custom_event("is_talking")
	ringtone.stop()


func play_dialogue(dialogue_path: String):
	var dialogue_resource = load(dialogue_path)
	if dialogue_resource:
		DialogueManager.show_dialogue_balloon_scene(dialogue_balloon, dialogue_resource, "start")

func on_phone_ended(resource: DialogueResource):
	GameState.set_task("TASK_2")
	EventsManager.emit_custom_event("is_ended")
	set_collision_layer_value(5, 0)
	await get_tree().create_timer(4.0).timeout
	ThoughtManager.show_thought("THOUGHT_3")
	await get_tree().create_timer(20.0).timeout
	ThoughtManager.show_thought("THOUGHT_4")
	GameState.set_task("TASK_3")
	$"../../../DayManager".start_day(1)

	queue_free()
