# GlobalSignals.gd
extends Node

signal custom_event(data)  # You can name it anything

func emit_custom_event(data):
	emit_signal("custom_event", data)
