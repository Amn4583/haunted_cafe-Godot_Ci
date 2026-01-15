extends CanvasLayer

@export var image: TextureRect
@export var title_label: Label
@export var text_label: RichTextLabel
@onready var close_button = $BackBtn
@onready var sound = $PaperSound
@onready var blur_overlay = $blur_overlay

var on_close_callback: Callable = func(): pass

func _ready():
	close_button.pressed.connect(_on_close_pressed)
	visible = false

func show_journal(journal_data: JournalData, on_close: Callable = func(): pass):
	EventsManager.emit_custom_event("is_talking")
	title_label.text = tr(journal_data.title)
	text_label.text = tr(journal_data.text)
	image.texture = journal_data.paper_image
	sound.play(0.3)
	on_close_callback = on_close
	visible = true

func _on_close_pressed():
	EventsManager.emit_custom_event("is_ended")
	visible = false
	on_close_callback.call()
