extends Control

@onready var drive_ui := $"../DriveUI"

func _ready() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_menu") and not event.is_echo():
		if visible:
			close_menu()
		else:
			open_menu()

		get_viewport().set_input_as_handled()


func open_menu() -> void:
	drive_ui.hide()
	show()
	get_tree().paused = true


func close_menu() -> void:
	drive_ui.show()
	hide()
	get_tree().paused = false


func _on_confirm_pressed() -> void:
	close_menu()
