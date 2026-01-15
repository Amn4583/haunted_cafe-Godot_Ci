extends Node3D

@export var tracks: Array[AudioStream] = []  # Add your music files in the Inspector
@onready var radio = $radio

var current_track_index: int = -1
var is_playing: bool = false

func _ready():
	randomize()
	# connect the finished signal to auto-play the next track
	radio.finished.connect(_on_track_finished)
	_play_random_track()

func _play_random_track():
	if tracks.is_empty():
		return
	var new_index = randi() % tracks.size()
	current_track_index = new_index
	radio.stream = tracks[new_index]
	radio.play()
	is_playing = true
	set_meta("interaction_name", "Pause tape")

func interact(player):
	if not radio.stream:
		return
	if is_playing:
		radio.stop()
		is_playing = false
		set_meta("interaction_name", "Run tape")
	else:
		radio.play()
		is_playing = true
		set_meta("interaction_name", "Pause tape")

func change_track():
	if tracks.is_empty():
		return
	var new_index = current_track_index
	while new_index == current_track_index and tracks.size() > 1:
		new_index = randi() % tracks.size()
	current_track_index = new_index
	radio.stream = tracks[new_index]
	if is_playing:
		radio.play()

# Called automatically when current song ends
func _on_track_finished():
	if is_playing:  # Only continue if radio is still on
		change_track()
