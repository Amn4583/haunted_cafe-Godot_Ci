extends Node

@onready var thought_label: RichTextLabel = null
@onready var bg_rect: TextureRect = null
var timer: Timer = null
var tween: Tween = null

func _ready():
	# Make sure a timer exists so we can await it
	if not timer:
		timer = Timer.new()
		timer.one_shot = true
		add_child(timer)

func set_thought_nodes(label_node: RichTextLabel, bg_node: TextureRect) -> void:
	thought_label = label_node
	bg_rect = bg_node
	thought_label.visible = false
	bg_rect.visible = false

func show_thought(thought_text: String, duration: float = 4.0) -> void:
	if not thought_label or not bg_rect:
		print("Thought nodes not set.")
		return
	
	# Stop existing tween/timer if any
	if tween:
		tween.kill()
	timer.stop()
	
	# Set initial state
	thought_label.text = tr(thought_text)
	thought_label.modulate.a = 0.0
	bg_rect.modulate.a = 0.0
	thought_label.visible = true
	bg_rect.visible = true
	
	# Fade in
	tween = create_tween()
	tween.tween_property(bg_rect, "modulate:a", 0.8, 0.3)
	tween.tween_property(thought_label, "modulate:a", 1.0, 0.3)
	
	# Start timer for await use
	timer.wait_time = duration
	timer.start()
	
	# Chain fade out after the timer
	tween.tween_interval(duration)
	tween.tween_property(thought_label, "modulate:a", 0.0, 0.5)
	tween.tween_property(bg_rect, "modulate:a", 0.0, 0.5)
	tween.tween_callback(Callable(self, "_clear_thought"))

func _clear_thought():
	if thought_label:
		thought_label.visible = false
	if bg_rect:
		bg_rect.visible = false
