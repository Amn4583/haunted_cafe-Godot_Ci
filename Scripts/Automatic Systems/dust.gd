
extends Area3D
@onready var sweep = $sweep
@onready var sweep_anim = $sweep_anim
func _ready():
	add_to_group("dust")
	connect("body_entered", Callable(self, "_on_body_entered"))

func _on_body_entered(body):
	if body.is_in_group("broom"):
		sweep.play()
		await sweep.finished
		queue_free()
		print("Broom cleaned me!")
