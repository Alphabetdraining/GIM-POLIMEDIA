extends Node2D

@onready var fade_rect: ColorRect = $FadeLayer/FadeRect

func _ready() -> void:
	
	fade_rect.visible = true
	fade_rect.modulate = Color(0, 0, 0, 1)
	await get_tree().process_frame
	Dialogic.signal_event.connect(_on_signal)
	fade_in()
	Dialogic.start("cut_3")


func fade_in(duration := 1.5):
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 0.0, duration)


func fade_out(duration := 1.5):
	fade_rect.visible = true
	var tween := create_tween()
	tween.tween_property(fade_rect, "modulate:a", 1.0, duration)


func _on_signal(signal_passed_in):
	match signal_passed_in:
		"cut_03":
			Dialogic.end_timeline()
			Dialogic.clear()

			
			fade_out()
			await get_tree().create_timer(0.6).timeout

			
			get_tree().change_scene_to_file(
				""
			)
