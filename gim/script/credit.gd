extends Control

const MAIN_MENU_PATH = "res://Scenes/main_menu.tscn"

func _ready() -> void:
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_out")

func _input(event: InputEvent) -> void:
	var is_mouse_click = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed
	var is_esc_pressed = event is InputEventKey and event.keycode == KEY_ESCAPE and event.pressed
	
	if is_mouse_click or is_esc_pressed:
		get_tree().change_scene_to_file(MAIN_MENU_PATH)
		
func transition_and_change(target_scene_path):
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_in")
	await $A/FadeTransition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene_path)
