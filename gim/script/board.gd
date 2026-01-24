extends Node
class_name Board

signal tetromino_locked
signal game_over

const ROW_COUNT = 20
const COLUMN_COUNT = 10

var tetrominos: Array[Tetromino] = []
@export var tetromino_scene : PackedScene  

func spawn_tetromino(type:Shared.Tetromino, is_next_piece, spawn_position):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino  
	
	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	
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
	for tetromino in tetrominos:
		var pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for piece in pieces:
			var y_location = piece.global_position.y 
			if y_location == -400:
				print("GAME OVER TRIGGERED")
				game_over.emit()
func clear_lines():
	var board_pieces = fill_board_pieces()
	clear_board_pieces(board_pieces)
func fill_board_pieces():
	var board_pieces = []
	
	for i in ROW_COUNT:
		board_pieces.append([])
		
	for tetromino in tetrominos:
		var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for piece in tetromino_pieces:
			var row  = (piece.global_position.y  + piece.get_size().y / 2) / piece.get_size().y + ROW_COUNT /2
			board_pieces[row -1].append(piece)
	return board_pieces
	
func clear_board_pieces(board_pieces):
	var i = ROW_COUNT - 1
	while i >= 0:
		if board_pieces[i].size() == COLUMN_COUNT:
			clear_row(board_pieces[i])
			board_pieces[i].clear()
			move_all_pieces_down(board_pieces, i)
			# JANGAN i -= 1 di sini
		else:
			i -= 1



			
func clear_row(row):
	for piece in row:
		piece.queue_free()
		
func move_all_pieces_down(board_pieces, cleared_row):
	for y in range(cleared_row - 1, -1, -1):
		for piece in board_pieces[y]:
			piece.position.y += piece.get_size().y
			board_pieces[y + 1].append(piece)
		board_pieces[y].clear()
