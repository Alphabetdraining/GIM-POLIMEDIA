extends Node
class_name Board

signal tetromino_locked
signal game_over
signal line_cleared(count: int)
const TILE_SIZE = 119

var grid := []
const ROW_COUNT = 16
const COLUMN_COUNT = 16

@onready var player = $"../Player"

var tetrominos: Array[Tetromino] = []
var cleared_lines_count = 0
@export var tetromino_scene : PackedScene  
func _ready():
	grid.resize(ROW_COUNT)
	for y in ROW_COUNT:
		grid[y] = []
		grid[y].resize(COLUMN_COUNT)
	await get_tree().process_frame 
	
func world_to_grid(pos: Vector2) -> Vector2i:
	var x = int(round(pos.x / TILE_SIZE)) + COLUMN_COUNT / 2
	var y = int(round(pos.y / TILE_SIZE)) + ROW_COUNT / 2
	return Vector2i(x, y)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var x = (grid_pos.x - COLUMN_COUNT / 2.0) * TILE_SIZE
	var y = (grid_pos.y - ROW_COUNT / 2.0) * TILE_SIZE
	return Vector2(x, y)

func spawn_tetromino(type:Shared.Tetromino, is_next_piece, spawn_position):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino  

	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	tetromino.player = player 

	if is_next_piece == false:
		var spawn_grid = Vector2i(COLUMN_COUNT / 2 - 1, 0)
		tetromino.position = grid_to_world(spawn_grid)


		tetromino.other_tetrominos = tetrominos
		tetromino.lock_tetromino.connect(on_tetromino_locked)
		add_child(tetromino)

func on_tetromino_locked(tetromino : Tetromino):
	tetrominos.append(tetromino)
	tetromino_locked.emit()
	#TODO check Game Over
	check_game_over()
	#Check clear line
	clear_lines()

func check_game_over():
	for tetromino in tetrominos:
		var pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for piece in pieces:
			var grid_pos = world_to_grid(piece.global_position)
			if grid_pos.y <= 0:
				game_over.emit()

func clear_lines():
	var board_pieces = fill_board_pieces()
	var lines_cleared_this_time = clear_board_pieces(board_pieces)
	if lines_cleared_this_time > 0:
		cleared_lines_count += lines_cleared_this_time
		line_cleared.emit(lines_cleared_this_time)
func fill_board_pieces():
	var board_pieces = []
	
	for i in ROW_COUNT:
		board_pieces.append([])
		
	for tetromino in tetrominos:
		var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for piece in tetromino_pieces:
			var grid_pos = world_to_grid(piece.global_position)
			if grid_pos.y >= 0 and grid_pos.y < ROW_COUNT:
				board_pieces[grid_pos.y].append(piece)


	return board_pieces
	
func clear_board_pieces(board_pieces):
	var i = ROW_COUNT - 1
	var lines_cleared = 0
	while i >= 0:
		if board_pieces[i].size() == COLUMN_COUNT:
			clear_row(board_pieces[i])
			board_pieces[i].clear()
			move_all_pieces_down(board_pieces, i)
			lines_cleared += 1
		else:
			i -= 1
	return lines_cleared



			
func clear_row(row):
	for piece in row:
		piece.queue_free()
		
func move_all_pieces_down(board_pieces, cleared_row):
	for y in range(cleared_row - 1, -1, -1):
		for piece in board_pieces[y]:
			piece.position.y += TILE_SIZE
			board_pieces[y + 1].append(piece)
		board_pieces[y].clear()
