@icon("./assets/icon.svg")
@tool
class_name DialogueLabel
extends RichTextLabel

## Emitted for each letter typed out.
signal spoke(letter: String, letter_index: int, speed: float)

## Emitted when the player skips the typing of dialogue.
signal skipped_typing()

## Emitted when typing starts
signal started_typing()

## Emitted when typing finishes.
signal finished_typing()

## [Deprecated] No longer emitted.
signal paused_typing(duration: float)

## The action to press to skip typing.
@export var skip_action: StringName = &"ui_cancel"

## The speed with which the text types out.
@export var seconds_per_step: float = 0.02

## Automatically have a brief pause when these characters are encountered.
@export var pause_at_characters: String = ".?!"

## Don't auto pause if the character after the pause is one of these.
@export var skip_pause_at_character_if_followed_by: String = ")\""

## Don't auto pause after these abbreviations (only if "." is in `pause_at_characters`)
@export var skip_pause_at_abbreviations: PackedStringArray = ["Mr", "Mrs", "Ms", "Dr", "etc", "eg", "ex"]

## The amount of time to pause when exposing a character present in `pause_at_characters`.
@export var seconds_per_pause_step: float = 0.3

var _already_mutated_indices: PackedInt32Array = []

## The current line of dialogue.
var dialogue_line:
	set(value):
		if value != dialogue_line:
			dialogue_line = value
			_update_text()
	get:
		return dialogue_line

## Whether the label is currently typing itself out.
var is_typing: bool = false:
	set(value):
		var is_finished: bool = _is_typing != value and value == false and _current_index >= _full_text.length()
		_is_typing = value
		if is_finished:
			finished_typing.emit()
	get:
		return _is_typing and not _is_awaiting_mutation
var _is_typing: bool = false

var _last_wait_index: int = -1
var _last_mutation_index: int = -1
var _waiting_seconds: float = 0
var _is_awaiting_mutation: bool = false

# new vars for realtime typing
var _full_text: String = ""
var _current_index: int = 0


func _process(delta: float) -> void:
	if _is_typing:
		if _current_index < _full_text.length():
			if _waiting_seconds > 0:
				_waiting_seconds -= delta
			if _waiting_seconds <= 0:
				_type_next(delta, _waiting_seconds)
		else:
			_mutate_inline_mutations(_full_text.length())
			is_typing = false


func _update_text() -> void:
	_full_text = dialogue_line.text
	text = ""

func type_out() -> void:
	_update_text()
	_current_index = 0
	_waiting_seconds = 0
	_last_wait_index = -1
	_last_mutation_index = -1
	_already_mutated_indices.clear()
	_is_awaiting_mutation = false

	is_typing = true
	started_typing.emit()

	await get_tree().process_frame

	if _full_text.is_empty():
		is_typing = false
	elif seconds_per_step == 0:
		text = ""
		append_text(_full_text)
		_mutate_remaining_mutations()
		is_typing = false


func skip_typing() -> void:
	# Stop all mutation waits and finish the line immediately
	_is_awaiting_mutation = false
	_waiting_seconds = 0

	# Clear and write full text instantly
	clear()
	append_text(_full_text)

	_mutate_remaining_mutations()
	_current_index = _full_text.length()

	is_typing = false
	skipped_typing.emit()


func _type_next(delta: float, seconds_needed: float) -> void:
	if _is_awaiting_mutation:
		return
	if _current_index >= _full_text.length():
		return

	if _last_mutation_index != _current_index:
		_last_mutation_index = _current_index
		_mutate_inline_mutations(_current_index)
		if _is_awaiting_mutation:
			return

	var waiting_seconds: float = seconds_per_pause_step if _should_auto_pause() else 0
	if _last_wait_index != _current_index and waiting_seconds > 0:
		_last_wait_index = _current_index
		_waiting_seconds += waiting_seconds
	else:
		var char := str(_full_text[_current_index])

		# 🪄 Detect if we're inside a BBCode tag
		if char == "[":
			# instantly write the whole tag
			var end_index := _full_text.find("]", _current_index)
			if end_index != -1:
				var tag_text := _full_text.substr(_current_index, end_index - _current_index + 1)
				append_text(tag_text)
				_current_index = end_index + 1
				_type_next(delta, seconds_needed)
				return

		append_text(char)
		spoke.emit(char, _current_index, _get_speed(_current_index))
		_current_index += 1

		seconds_needed += seconds_per_step * (1.0 / _get_speed(_current_index))
		if seconds_needed > delta:
			_waiting_seconds += seconds_needed
		else:
			_type_next(delta, seconds_needed)

func _get_speed(at_index: int) -> float:
	var speed: float = 1
	for index in dialogue_line.speeds:
		if index > at_index:
			return speed
		speed = dialogue_line.speeds[index]
	return speed


func _mutate_remaining_mutations() -> void:
	for i in range(_current_index, _full_text.length() + 1):
		_mutate_inline_mutations(i)


func _mutate_inline_mutations(index: int) -> void:
	for inline_mutation in dialogue_line.inline_mutations:
		if inline_mutation[0] > index:
			return
		if inline_mutation[0] == index and not _already_mutated_indices.has(index):
			_is_awaiting_mutation = true
			await Engine.get_singleton("DialogueManager")._mutate(inline_mutation[1], dialogue_line.extra_game_states, true)
			_is_awaiting_mutation = false
	_already_mutated_indices.append(index)


func _should_auto_pause() -> bool:
	if _current_index == 0:
		return false

	var parsed_text: String = _full_text
	if _current_index >= parsed_text.length():
		return false

	if parsed_text[_current_index] in skip_pause_at_character_if_followed_by.split():
		return false

	if _current_index > 3 and parsed_text[_current_index - 1] == ".":
		var possible_number: String = parsed_text.substr(_current_index - 2, 3)
		if str(float(possible_number)).pad_decimals(1) == possible_number:
			return false

	if "." in pause_at_characters and parsed_text[_current_index - 1] == ".":
		for abbreviation in skip_pause_at_abbreviations:
			if _current_index >= abbreviation.length():
				var previous_characters: String = parsed_text.substr(_current_index - abbreviation.length() - 1, abbreviation.length())
				if previous_characters == abbreviation:
					return false

	var other_pause_characters: PackedStringArray = pause_at_characters.replace(".", "").split()
	if _current_index > 1 and parsed_text[_current_index - 1] in other_pause_characters and parsed_text[_current_index] in other_pause_characters:
		return false

	return parsed_text[_current_index - 1] in pause_at_characters.split()
