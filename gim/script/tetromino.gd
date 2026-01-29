extends Node2D
class_name Tetromino

signal lock_tetromino(tetromino: Tetromino)

# ================= GRID LIMIT =================
var bounds = {
	"min_x": -900,
	"max_x": 900,
	"max_y": 939
}
# ================= MOVE SMOOTH =================
var target_position: Vector2
@export var smooth_speed = 12.0
# ================= STATE SYSTEM =================
enum DropState {
	FLOATING,
	FALL_PREPARE,
	ROTATING,
	HARD_DROP,
	NORMAL
}

var drop_state = DropState.FLOATING
var state_timer = 0.0

# ================= SETTINGS =================
@export var float_time = 4.0
@export var rotate_time = 2.0
@export var rotate_interval = 0.2

@export var follow_interval = 0.1
var follow_timer_step = 0.0

@export var fall_speed = 0.5
@export var hard_drop_speed = 0.08

# ================= FLAGS =================
var is_locked = false
var auto_hard_dropped = false

# ================= PLAYER FOLLOW =================
var player
@export var follow_player = true
@export var follow_duration = 3.0
var follow_timer = 0.0

# ================= TETROMINO DATA =================
var rotation_index = 0
var wall_kicks
var tetromino_data
var is_next_piece
var tetromino_cells
var pieces = []
var other_tetrominos: Array[Tetromino] = []

# ================= VISUAL FLOAT =================
var float_wave = 0.0

# ================= NODE =================
@onready var timer = $Timer
@onready var piece_scene = preload("res://Scenes/piece.tscn")

# =================================================
func _ready() -> void:
	tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	

	is_locked = false
	follow_timer = 0
	auto_hard_dropped = false
	state_timer = 0
	drop_state = DropState.FLOATING

	timer.stop() # disable classic gravity

	for cell in tetromino_cells:
		var piece = piece_scene.instantiate() as Piece
		pieces.append(piece)
		add_child(piece)
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * Board.TILE_SIZE

	var tile = Board.TILE_SIZE
	bounds.min_x = - (Board.COLUMN_COUNT / 2.0) * tile
	bounds.max_x = (Board.COLUMN_COUNT / 2.0) * tile - tile
	bounds.max_y = (Board.ROW_COUNT / 2.0) * tile
	target_position = global_position
	if is_next_piece == false:
		#position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz


# ================= INPUT =================
func _input(_event):
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_tetromino(-1)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_tetromino(1)


# ================= GRID MOVE =================
func move(direction: Vector2) -> bool:
	var new_position = calculate_global_position(direction, target_position)
	if new_position:
		target_position = new_position
		return true
	return false


func calculate_global_position(direction: Vector2, start_pos: Vector2):
	if is_colliding_with_other_tetromino(direction, start_pos):
		return null
	if !is_within_game_bounds(direction, start_pos):
		return null
	return start_pos + direction * Board.TILE_SIZE

func is_within_game_bounds(direction: Vector2, start_pos):
	for piece in pieces:
		var pos = piece.position + start_pos + direction * piece.get_size()
		if pos.x < bounds.min_x or pos.x > bounds.max_x or pos.y >= bounds.max_y:
			return false
	return true

func is_colliding_with_other_tetromino(direction: Vector2, start_pos):
	for tetromino in other_tetrominos:
		var others = tetromino.get_children().filter(func(c): return c is Piece)
		for o in others:
			for p in pieces:
				var my_pos = start_pos + p.position + direction * Board.TILE_SIZE

				var other_pos = tetromino.global_position + o.position

				if my_pos.distance_to(other_pos) < Board.TILE_SIZE * 0.5:
					return true
	return false



# ================= ROTATION =================
func rotate_tetromino(direction: int):
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return

	var old = rotation_index
	apply_rotation(direction)
	rotation_index = wrap(rotation_index + direction, 0, 4)

	if !test_wall_kicks(rotation_index, direction):
		rotation_index = old
		apply_rotation(-direction)

func test_wall_kicks(rot_i: int, dir: int):
	var index = get_wall_kick_index(rot_i, dir)
	for i in wall_kicks[0].size():
		if move(wall_kicks[index][i]):
			return true
	return false

func get_wall_kick_index(rot_i: int, dir: int):
	var idx = rot_i * 2
	if dir < 0:
		idx -= 1
	return wrap(idx, 0, wall_kicks.size())

func apply_rotation(dir: int):
	var mat = Shared.clockwise_rotation_matrix if dir == 1 else Shared.counter_clockwise_rotation_matrix
	var cells = Shared.cells[tetromino_data.tetromino_type]

	for i in cells.size():
		cells[i] = mat[0] * cells[i].x + mat[1] * cells[i].y

	for i in pieces.size():
		pieces[i].position = cells[i] * Board.TILE_SIZE



# ================= HARD DROP =================
func hard_drop():
	if is_locked:
		return

	set_process_input(false)
	while move(Vector2.DOWN):
		await get_tree().create_timer(hard_drop_speed).timeout
	lock()


# ================= CINEMATIC STATE MACHINE =================
func _physics_process(delta):
	if is_next_piece or is_locked:
		return

	state_timer += delta

	match drop_state:

		DropState.FLOATING:
			if follow_player and player:
				follow_player_logic(delta)

			if state_timer >= float_time:
				state_timer = 0
				drop_state = DropState.FALL_PREPARE

		DropState.FALL_PREPARE:
			move(Vector2.DOWN)
			state_timer = 0
			drop_state = DropState.HARD_DROP

		#DropState.ROTATING:
			#if state_timer >= rotate_interval:
				#state_timer = 0
				#rotate_tetromino(1)
				#rotate_time -= rotate_interval
#
			#if rotate_time <= 0:
				#drop_state = DropState.HARD_DROP

		DropState.HARD_DROP:
			hard_drop()
			drop_state = DropState.NORMAL


# ================= VISUAL FLOAT (NO GRID DAMAGE) =================
func _process(delta):
	global_position = global_position.lerp(target_position, delta * smooth_speed)

	if drop_state == DropState.FLOATING:
		float_wave += delta * 2.0
		for piece in pieces:
			piece.position.y += sin(float_wave) * 0.2



# ================= PLAYER FOLLOW =================
func follow_player_logic(_delta):
	if not player:
		return
	
	var player_x = player.global_position.x
	var tile_size = pieces[0].get_size().x
	var snapped_x = round(player_x / tile_size) * tile_size
	
	var leftmost = 0.0
	var rightmost = 0.0
	
	for piece in pieces:
		if piece.position.x < leftmost:
			leftmost = piece.position.x
		if piece.position.x > rightmost:
			rightmost = piece.position.x
	
	var min_bound = bounds.min_x - leftmost
	var max_bound = bounds.max_x - rightmost
	
	snapped_x = clamp(snapped_x, min_bound, max_bound)
	
	if abs(snapped_x - target_position.x) > tile_size * 0.5:
		target_position.x = snapped_x


# ================= LOCK =================
func lock():
	if is_locked:
		return

	var board = get_parent() as Board
	var piece = pieces[0]

	# ambil posisi grid dari salah satu piece
	var grid_pos = board.world_to_grid(piece.global_position)

	# konversi balik ke world (grid snapping)
	var world_pos = board.grid_to_world(grid_pos)

	# hitung offset piece ke root tetromino
	var offset = piece.global_position - global_position

	# kunci tetromino ke grid
	global_position = world_pos - offset

	is_locked = true
	lock_tetromino.emit(self)
	set_process_input(false)
	print(board.world_to_grid(pieces[0].global_position))

	
