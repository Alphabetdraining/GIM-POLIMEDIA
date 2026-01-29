extends CanvasLayer
class_name UI

@onready var center_container = $CenterContainer
@onready var mc_panel = $MCPanel
@onready var enemy_panel = $EnemyPanel
@onready var mc_portrait = $MCPanel/VBoxContainer/Portrait
@onready var enemy_portrait = $EnemyPanel/VBoxContainer/Portrait
@onready var hp_label = $MCPanel/VBoxContainer/HPLabel
@onready var enemy_hp_label = $EnemyPanel/VBoxContainer/HPLabel

@export var enemy_portrait_normal: Texture2D
@export var enemy_portrait_hurt: Texture2D
@export var enemy_portrait_dying: Texture2D
@export var music_menu: AudioStream

var mc_portraits = {
	3: null,
	2: null,
	1: null
}

var enemy_hp = 6
var max_enemy_hp = 6

func _ready():
	if center_container:
		center_container.hide()
	update_hp_display(3)
	update_enemy_hp_display(enemy_hp)

func show_game_over():
	if center_container:
		center_container.show()

func update_hp_display(hp: int):
	print("update_hp_display called with HP:", hp)
	if hp_label:
		hp_label.text = "HP: %d/3" % hp
		print("HP Label updated successfully")
	else:
		print("ERROR: hp_label is null!")
	
	if mc_portrait and mc_portraits.has(hp):
		var portrait_texture = mc_portraits[hp]
		if portrait_texture:
			mc_portrait.texture = portrait_texture

func update_enemy_hp_display(hp: int):
	enemy_hp = hp

	if enemy_hp_label:
		enemy_hp_label.text = "HP: %d/%d" % [enemy_hp, max_enemy_hp]

	if not enemy_portrait:
		return

	if enemy_hp >= 7:
		enemy_portrait.texture = enemy_portrait_normal
	elif enemy_hp >= 4:
		enemy_portrait.texture = enemy_portrait_hurt
	else:
		enemy_portrait.texture = enemy_portrait_dying

func damage_enemy(amount: int):
	enemy_hp -= amount
	enemy_hp = max(enemy_hp, 0)
	update_enemy_hp_display(enemy_hp)
	
	if enemy_hp <= 0:
		AudioManager.stop_music()
		print("Enemy defeated!")
		get_tree().change_scene_to_file(
				"res://Scenes/cutscene_4.tscn"
			)

func _on_button_pressed():
	get_tree().paused = false
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()
