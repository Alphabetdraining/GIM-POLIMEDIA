extends Node2D

var button_type = null

func _ready():
	$A/CircleTransition.show()
	$A/CircleTransition/AnimationPlayer.play("BlackToFade")

func _on_new_game_pressed():
	print("new game pressed")
	transition_and_change("res://scene/main_menu.tscn")

func _on_continue_pressed():
	transition_and_change("res://scene/main_menu.tscn")

func _on_credit_pressed():
	transition_and_change("res://scene/credit.tscn")

func _on_quit_pressed():
	get_tree().quit()

func transition_and_change(target_scene_path):
	$A/CircleTransition.show()
	$A/CircleTransition/AnimationPlayer.play("FadeToBlack")
	await $A/CircleTransition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene_path)

#if button_type == "start" :
#		get_tree().change_scene_to_file("res://scene/main_menu.tscn")
		
#	elif button_type == "continue" :
#		get_tree().change_scene_to_file("res://scene/main_menu.tscn")
		
#	elif button_type == "credit" :
#		get_tree().change_scene_to_file("res://scene/credit.tscn")
