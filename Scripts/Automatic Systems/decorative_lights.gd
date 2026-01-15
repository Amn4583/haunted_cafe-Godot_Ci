extends Node3D

@export var leds : Array[AnimatedSprite3D]
@export var speed := 6.0
@export var pattern_length := 4

func _process(delta):
	var t = int((Time.get_ticks_msec() / 1000.0) * speed)
	var i := 0
	for led in leds:
		var on = int((t + i) % pattern_length) == 0
		led.frame = 1 if on else 0
		i += 1
