extends CanvasLayer

var paused = false

func _ready():
	hide()
	process_mode = Node.PROCESS_MODE_ALWAYS

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		toggle_pause()

func toggle_pause():
	paused = !paused
	get_tree().paused = paused
	
	if paused:
		show() 
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE) 
	else:
		hide() 
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _on_continue_pressed() -> void:
	toggle_pause()


func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
