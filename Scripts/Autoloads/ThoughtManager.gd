# ThoughtManager.gd
extends Node

var thought_label: Label = null
var timer :Timer = null

func set_thought_label(label_node: Label) -> void:
	thought_label = label_node

func show_thought(thought_text: String, duration: float = 4.0) -> void:
	if thought_label:
		thought_label.text = thought_text
		_start_timer(duration)
	else:
		print("Thought label not set.")

func _start_timer(duration: float):
	if timer:
		timer.stop()
	else:
		timer = Timer.new()
		add_child(timer)
		timer.one_shot = true
		timer.connect("timeout", Callable(self, "_clear_thought"))
	
	timer.wait_time = duration
	timer.start()

func _clear_thought():
	if thought_label:
		thought_label.text = ""
