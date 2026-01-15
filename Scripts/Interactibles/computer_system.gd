extends StaticBody3D

@onready var cam = $Camera3D
var cam_pos = false
@onready var fade_anim = $"../Control/Animations/Fade"
@onready var fade_obj = $"../Control/Animations/Fade/ColorRect"
@onready var Os = $Os
@onready var UI = $"../Control/Inspection"
@onready var joystick = $"../Control/VirtualJoystick"
@onready var player = $"../CharacterBody3D"

func _ready() -> void:
	set_meta("interaction_name", "Use")
	cam.current = false
	fade_obj.visible = true
	Os.visible = false
	
func interact(player):
	if not cam_pos:
		switch_camera()
	else:
		switch_back()


func switch_camera():
	fade_obj.visible = true
	fade_anim.play("fade_in")
	await fade_anim.animation_finished
	fade_anim.play("fade_out")
	cam.current = true
	cam_pos = true
	Os.visible = true
	print("Using Computer")
	#UI.visible = false
	joystick.visible = false
	EventsManager.emit_custom_event("using_pc")
	
func switch_back():
	fade_anim.play("fade_in")
	await fade_anim.animation_finished
	fade_anim.play("fade_out")
	cam.current = false
	cam_pos = false
	Os.visible = false
	print("Stopped Computer")
	#UI.visible = true
	joystick.visible = true
	player.visible = true
	EventsManager.emit_custom_event("exit_pc")


func _on_exit_button_pressed() -> void:
	switch_back()
