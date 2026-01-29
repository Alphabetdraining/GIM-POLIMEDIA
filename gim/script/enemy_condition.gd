extends Control

@onready var portrait = $VBoxContainer/Portrait
@onready var ui = get_node("/root/Main/UI")

@export var portrait_normal: Texture2D
@export var portrait_hurt: Texture2D
@export var portrait_dying: Texture2D

func _on_hp_changed(hp):
	if hp >= 7:
		portrait.texture = portrait_normal
	elif hp >= 4:
		portrait.texture = portrait_hurt
	else:
		portrait.texture = portrait_dying
