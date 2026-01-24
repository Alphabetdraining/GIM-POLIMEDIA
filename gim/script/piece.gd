extends Area2D

class_name Piece
@onready var sprite_2d = $Sprite2D
@onready var collision_shape = $CollisionShape2D

func set_texture(texture: Texture2D):
	sprite_2d.texture = texture
	
func get_size():
	return collision_shape.shape.get_rect().size
