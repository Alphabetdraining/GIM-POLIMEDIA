extends Node

var current_tetromino
var is_game_over = false
@onready var ui =$"../UI" as UI
@onready var board = $"../board" as Board

func _ready():
	current_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(current_tetromino,false, null)
	board.tetromino_locked.connect(on_tetromino_locked)
	board.game_over.connect(on_game_over)
func on_tetromino_locked():
	if is_game_over:	
		return
	var new_tetromino = Shared.Tetromino.values().pick_random()
	board.spawn_tetromino(new_tetromino, false, null)
func on_game_over():
	is_game_over = true
	ui.show_game_over()
