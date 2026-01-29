extends Node2D

var button_type = null
@export var music_menu: AudioStream

func _ready() -> void:
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_out")

	if music_menu:
		await $A/FadeTransition/AnimationPlayer.animation_finished
		AudioManager.play_music(music_menu)
		
func _on_new_game_pressed() -> void:
	transition_and_change("res://Scenes/cutscene_1.tscn")

func _on_continue_pressed() -> void:
	transition_and_change("res://Scenes/main.tscn")

func _on_credit_pressed() -> void:
	transition_and_change("res://Scenes/credit.tscn")

func _on_quit_pressed() -> void:
	get_tree().quit()

func transition_and_change(target_scene_path) -> void:
	$A/FadeTransition.show()
	$A/FadeTransition/AnimationPlayer.play("Fade_in")
	await $A/FadeTransition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene_path)

func circle_transition(target_scene_path) -> void:
	$A/CircleTransition.show()
	$A/CircleTransition/AnimationPlayer.play("Fade_in")
	await $A/CircleTransition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file(target_scene_path)
