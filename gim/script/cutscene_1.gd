extends Node2D

@onready var fade_rect: ColorRect = $FadeLayer/FadeRect
@export var music_menu: AudioStream

func _ready() -> void:
	AudioManager.stop_music()
	
	fade_rect.visible = true
	fade_rect.modulate = Color(0, 0, 0, 1)
	await get_tree().process_frame
	Dialogic.signal_event.connect(_on_signal)
	fade_in()
	Dialogic.start("cut_1")


func fade_in(duration := 2.5):
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)


func fade_out(duration := 2.5):
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)


func _on_signal(signal_passed_in):
	match signal_passed_in:
		"cut_01":
			Dialogic.end_timeline()
			Dialogic.clear()

			# FADE OUT
			fade_out()
			await get_tree().create_timer(1.6).timeout

			# PINDAH SCENE
			get_tree().change_scene_to_file(
				"res://Scenes/cutscene_2.tscn"
			)
