extends Node

signal custom_event(data)

# Add these two:
signal photocopy_request(unique_code, copies_needed)
signal print_request(unique_code)
signal scan_request(unique_code, copies_needed)
signal UI_request(unique_code, copies_needed)


func emit_custom_event(data):
	emit_signal("custom_event", data)

# Emitters for your new signals (optional helpers)
func emit_photocopy_request(unique_code, copies_needed):
	emit_signal("photocopy_request", unique_code, copies_needed)
	
func emit_scan_request(unique_code, copies_needed):
	emit_signal("scan_request", unique_code, copies_needed)

func emit_UI_request(unique_code, copies_needed):
	emit_signal("UI_request", unique_code, copies_needed)
	print("UI Requested.")

func emit_print_request(unique_code):
	emit_signal("print_request", unique_code)
