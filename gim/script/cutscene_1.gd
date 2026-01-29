extends Node2D

@export var music_menu: AudioStream

func _ready() -> void:
	AudioManager.stop_music()
	
	Dialogic.signal_event.connect(_on_signal)
	Dialogic.start("cut_1")

func _on_signal(signal_passed_in):
	match signal_passed_in:
		"cut_01":
			Dialogic.end_timeline()

			$A/FadeTransition.show()
			$A/FadeTransition/AnimationPlayer.play("Fade_in")
			await $A/FadeTransition/AnimationPlayer.animation_finished
			Dialogic.clear()
			

			# PINDAH SCENE
			get_tree().change_scene_to_file(
				"res://Scenes/cutscene_2.tscn"
			)
