extends Control

@onready var portrait = $VBoxContainer/Portrait
@onready var player = get_node("/root/Main/Player")

@export var portrait_full: Texture2D
@export var portrait_hurt: Texture2D
@export var portrait_critical: Texture2D

func _ready():
	player.hp_changed.connect(_on_hp_changed)
	_on_hp_changed(player.hp)

func _on_hp_changed(hp):
	if hp >= 3:
		portrait.texture = portrait_full
	elif hp == 2:
		portrait.texture = portrait_hurt
	else:
		portrait.texture = portrait_critical
