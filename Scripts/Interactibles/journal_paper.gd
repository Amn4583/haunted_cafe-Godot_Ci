extends StaticBody3D

@export var journal_data: JournalData
@export var journal_ui: CanvasLayer

func _ready() -> void:
	set_meta("interaction_name", journal_data.name)
	
func interact(player):
	await get_tree().process_frame
	journal_ui.show_journal(journal_data, func():
		print("Journal closed.")
	)
