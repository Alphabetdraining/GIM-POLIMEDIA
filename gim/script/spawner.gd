extends Node

var current_tetromino
var is_game_over = false
var hit_count = 0

@onready var ui = $"../UI" as UI
@onready var board = $"../board" as Board
@onready var player = $"../Player"
@export var powerup_scene: PackedScene = preload("res://Scenes/powerup.tscn")

func _ready():
	current_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino, false, null)
	board.tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)
	board.line_cleared.connect(on_line_cleared)
	
	if player:
		player.hp_changed.connect(on_player_hp_changed)
		player.player_died.connect(on_player_died)
	
	await get_tree().create_timer(0.1).timeout
	if player and ui:
		ui.update_hp_display(player.hp)
		print("Initial HP Display:", player.hp)

func on_tetromino_locked():
	if is_game_over:
		return
	var new_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(new_tetromino, false, null)

func on_game_over():
	is_game_over = true
	ui.show_game_over()

func on_line_cleared(count: int):
	print("Lines cleared: ", count)
	ui.damage_enemy(count)
	hit_count += count
	
	if hit_count >= 3:
		spawn_random_powerup()
		hit_count = 0

func on_player_hp_changed(new_hp: int):
	print("Player HP changed to:", new_hp)
	if ui:
		ui.update_hp_display(new_hp)
	else:
		print("ERROR: UI is null!")

func on_player_died():
	is_game_over = true

func spawn_random_powerup():
	if powerup_scene:
		var powerup = powerup_scene.instantiate()
		powerup.position = Vector2(randf_range(-200, 200), -400)
		get_parent().add_child(powerup)
		print("Power-up spawned!")
