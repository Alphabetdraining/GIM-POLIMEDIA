class_name Main extends Node

func _ready() -> void:
	$Transition/CircleTransition.show()
	$Transition/CircleTransition/AnimationPlayer.play("BlackToFade")
