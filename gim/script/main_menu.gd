class_name MainMenu extends Node2D

var button_type = null

func _ready() -> void:
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_out")

func _on_new_game_pressed():
	transition_and_change("res://Scenes/main.tscn")

func _on_continue_pressed():
	transition_and_change("res://Scenes/main.tscn")

func _on_credit_pressed():
	transition_and_change("res://Scenes/credit.tscn")

func _on_quit_pressed():
	get_tree().quit()

func transition_and_change(target_scene_path):
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_in")
	await $A/FadeTransition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene_path)
