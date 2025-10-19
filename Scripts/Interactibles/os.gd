extends CanvasLayer

signal print_requested

@onready var app_container = $Apps
@onready var internet_app = $Apps/internet
@onready var mail_app = $Apps/mail
@onready var print_app = $Apps/print

func _ready():
	# Hide all apps at start
	for app in app_container.get_children():
		app.visible = false

func _on_InternetButton_pressed():
	_open_app(internet_app)

func _on_MailButton_pressed():
	_open_app(mail_app)

func _on_PrintButton_pressed():
	_open_app(print_app)

func _open_app(app: Control):
	for a in app_container.get_children():
		a.visible = false
	app.visible = true

# Call this from PrintApp's "Print" button
func request_print():
	emit_signal("print_requested")

func close_app(app: Control):
	app.visible = false

func _on_internet_close_pressed() -> void:
	close_app(internet_app)


func _on_print_close_pressed() -> void:
	close_app(print_app)

func _on_mail_close_pressed() -> void:
	close_app(mail_app)
