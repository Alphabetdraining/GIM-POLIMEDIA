extends Control

var button_type = null

func _ready():
	$A/CircleTransition.show()
	$A/CircleTransition/AnimationPlayer.play("BlackToFade")
	
func _on_button_pressed():
	transition_and_change("res://scene/main_menu.tscn")

func transition_and_change(target_scene_path):
	$A/CircleTransition.show()
	$A/CircleTransition/AnimationPlayer.play("FadeToBlack")
	await $A/CircleTransition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene_path)
