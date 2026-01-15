extends CanvasLayer

@onready var label = $Panel/TaskLabel
@onready var panel = $Panel
var tween: Tween
@onready var task_sound = $Task_snd
@onready var flash_rect = $flash_rect

func _ready():
	GameState.task_changed.connect(_on_task_changed)
	panel.modulate.a = 0.0  # Start invisible
	
	# Start invisible & disabled
	flash_rect.visible = false
	flash_rect.modulate = Color(1, 1, 1, 0.0)
	
func _on_task_changed(new_task):
	# If already visible, fade out first, then change text
	task_sound.play()
	if panel.modulate.a > 0.05:
		_fade_out_then_change(new_task)
	else:
		# If it's the first time, just fade in with new text
		label.text = "• " + new_task
		_fade_in()

func _fade_out_then_change(new_task):
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.6).set_trans(Tween.TRANS_SINE)
	tween.tween_callback(Callable(self, "_update_text_and_fade_in").bind(new_task))

func _update_text_and_fade_in(new_task):
	label.text = "• " + new_task
	_fade_in()

func _fade_in():
	if tween:
		tween.kill()

	tween = create_tween()
	tween.tween_property(panel, "modulate:a", 1.0, 0.6).set_trans(Tween.TRANS_SINE)

# Call this to flash (intensity 0..1, duration in seconds)
func flash_blindness(intensity: float = 1.0, duration: float = 0.5) -> void:
	intensity = clamp(intensity, 0.0, 1.0)
	duration = max(duration, 0.01)
	flash_rect.visible = true
	# Immediately set the starting alpha
	flash_rect.modulate = Color(1, 1, 1, intensity)

	# Create a scene-tree tween and fade alpha to 0
	var tween = create_tween()
	tween.tween_property(flash_rect, "modulate:a", 0.0, duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# wait for tween to finish then hide the rect
	await tween.finished
	flash_rect.visible = false
