extends Sprite2D
class_name Claw

@export var hold_offset = Vector2(0, -128) # posisi cakar di atas blok
var target: Node2D

func set_target(t):
	target = t

func _process(delta):
	if target:
		global_position = target.global_position + hold_offset
