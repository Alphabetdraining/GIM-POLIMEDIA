extends Node
class_name Board

signal tetromino_locked
signal game_over
signal line_cleared(count: int)

# ================= GRID SETTINGS =================
const TILE_SIZE = 128 # sesuai asset kamu
const ROW_COUNT = 16
const COLUMN_COUNT = 16

var grid := []
var tetrominos: Array[Tetromino] = []
var cleared_lines_count = 0

@onready var player = $"../Player"
@export var tetromino_scene : PackedScene

# ================= READY =================
func _ready():
	grid.resize(ROW_COUNT)
	for y in range(ROW_COUNT):
		grid[y] = []
		grid[y].resize(COLUMN_COUNT)

	await get_tree().process_frame

# ================= GRID CONVERSION =================
func world_to_grid(pos: Vector2) -> Vector2i:
	# floor, bukan round!
	var x = int(floor(pos.x / TILE_SIZE)) + COLUMN_COUNT / 2
	var y = int(floor(pos.y / TILE_SIZE)) + ROW_COUNT / 2
	return Vector2i(x, y)

func grid_to_world(grid_pos: Vector2i) -> Vector2:
	var x = (grid_pos.x - COLUMN_COUNT / 2) * TILE_SIZE
	var y = (grid_pos.y - ROW_COUNT / 2) * TILE_SIZE
	return Vector2(x, y)

# ================= SPAWN =================
func spawn_tetromino(type: Shared.Tetromino, is_next_piece := false):
	var tetromino_data = Shared.data[type]
	var tetromino = tetromino_scene.instantiate() as Tetromino
	
	tetromino.tetromino_data = tetromino_data
	tetromino.is_next_piece = is_next_piece
	tetromino.player = player
	
	if not is_next_piece:
		var spawn_grid = Vector2i(COLUMN_COUNT / 2 - 2, 0)
		tetromino.global_position = grid_to_world(spawn_grid)
		tetromino.target_position = tetromino.global_position
		
		tetromino.other_tetrominos = tetrominos
		tetromino.lock_tetromino.connect(on_tetromino_locked)
		add_child(tetromino)

# ================= LOCK =================
func on_tetromino_locked(tetromino: Tetromino):
	tetrominos.append(tetromino)
	tetromino_locked.emit()
	
	check_game_over()
	clear_lines()

# ================= GAME OVER =================
func check_game_over():
	for tetromino in tetrominos:
		var pieces = tetromino.get_children().filter(func(c): return c is Piece)
		for piece in pieces:
			var grid_pos = world_to_grid(piece.global_position)
			if grid_pos.y <= 0:
				game_over.emit()
				return

# ================= LINE CLEAR =================
func clear_lines():
	var board_pieces = fill_board_pieces()
	var cleared = clear_board_pieces(board_pieces)
	
	if cleared > 0:
		cleared_lines_count += cleared
		line_cleared.emit(cleared)

# ================= FILL GRID =================
func fill_board_pieces():
	var board_pieces = []
	for i in range(ROW_COUNT):
		board_pieces.append([])
	
	for tetromino in tetrominos:
		var pieces = tetromino.get_children().filter(func(c): return c is Piece)
		for piece in pieces:
			var grid_pos = world_to_grid(piece.global_position)
			if grid_pos.y >= 0 and grid_pos.y < ROW_COUNT:
				board_pieces[grid_pos.y].append(piece)
	
	return board_pieces

# ================= CLEAR GRID =================
func clear_board_pieces(board_pieces):
	var y = ROW_COUNT - 1
	var cleared = 0
	
	while y >= 0:
		if board_pieces[y].size() == COLUMN_COUNT:
			clear_row(board_pieces[y])
			board_pieces[y].clear()
			move_all_pieces_down(board_pieces, y)
			cleared += 1
		else:
			y -= 1
	
	return cleared

func clear_row(row):
	for piece in row:
		piece.queue_free()

# ================= DROP ABOVE PIECES =================
func move_all_pieces_down(board_pieces, cleared_row):
	for y in range(cleared_row - 1, -1, -1):
		for piece in board_pieces[y]:
			piece.position.y += TILE_SIZE
			board_pieces[y + 1].append(piece)
		board_pieces[y].clear()
