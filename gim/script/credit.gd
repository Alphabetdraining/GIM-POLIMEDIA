class_name Credit extends Control

var button_type = null

func _ready() -> void:
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_out")
	
func _on_button_pressed():
	transition_and_change("res://Scenes/main_menu.tscn")

func transition_and_change(target_scene_path):
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_in")
	await $A/FadeTransition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene_path)
