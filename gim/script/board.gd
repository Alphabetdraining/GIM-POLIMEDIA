extends Node
class_name Board

signal tetromino_locked
signal game_over
signal line_cleared(count: int)

const ROW_COUNT = 20
const COLUMN_COUNT = 20

@onready var player = $"../Player"

var tetrominos: Array[Tetromino] = []
var cleared_lines_count = 0
@export var tetromino_scene : PackedScene  
func _ready():
	await get_tree().process_frame 

func spawn_tetromino(type:Shared.Tetromino, is_next_piece, spawn_position):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino  

	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	tetromino.player = player 

	if is_next_piece == false:
		tetromino.position = tetromino_data.spawn_position
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
	# ambil batas spawn dari tetromino data pertama (atau hardcode)
	var spawn_y = Shared.data[Shared.Tetromino.I].spawn_position.y

	for tetromino in tetrominos:
		var pieces = tetromino.get_children().filter(func(c): return c is Piece)
		
		for piece in pieces:
			var y = piece.global_position.y
			
			# jika ada block di atas spawn line → GAME OVER
			if y <= spawn_y:
				print("GAME OVER TRIGGERED AT:", y)
				game_over.emit()
				return

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
			var piece_size = piece.get_size().y
			var row = round((piece.global_position.y + piece_size / 2) / piece_size + ROW_COUNT / 2)
			if row >= 1 and row <= ROW_COUNT:
				board_pieces[row - 1].append(piece)
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
			piece.position.y += piece.get_size().y
			board_pieces[y + 1].append(piece)
		board_pieces[y].clear()
