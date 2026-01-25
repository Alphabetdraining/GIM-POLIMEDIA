extends Node2D

class_name Tetromino 

signal lock_tetromino(tetromino: Tetromino)

var bounds = {
	"min_x": -262,
	"max_x": 267,
	"max_y": 542
}
@export var follow_interval = 0.1
var follow_timer_step = 0.0


var player
@export var follow_player = true
@export var follow_duration = 2.0 # detik mengikuti player
var follow_timer = 0.0
var auto_hard_dropped = false

var rotation_index = 0
var wall_kicks
var tetromino_data
var is_next_piece
var tetromino_cells
var pieces = []
var other_tetrominos: Array[Tetromino] = []
@export var hard_drop_speed = 0.02
@onready var timer = $Timer
@onready var piece_scene = preload("res://Scenes/piece.tscn")
func  _ready() -> void:
	tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for cell in tetromino_cells:
		var piece = piece_scene.instantiate() as Piece
		pieces.append(piece)
		add_child(piece)
		piece.set_texture(tetromino_data.piece_texture)
		piece.position = cell * piece.get_size()
	
	if is_next_piece == false:
		position = tetromino_data.spawn_position
		wall_kicks = Shared.wall_kicks_i if tetromino_data.tetromino_type == Shared.Tetromino.I else Shared.wall_kicks_jlostz
		
func _input(event):
	if Input.is_action_just_pressed("left"):
		move(Vector2.LEFT)
	elif Input.is_action_just_pressed("right"):
		move(Vector2.RIGHT)
	elif Input.is_action_just_pressed("down"):
		move(Vector2.DOWN)
	#elif Input.is_action_just_pressed("hard_drop"):
		#hard_drop()
	elif Input.is_action_just_pressed("rotate_left"):
		rotate_tetromino(-1)
	elif Input.is_action_just_pressed("rotate_right"):
		rotate_tetromino(1)
func move(direction: Vector2)->bool:
	var new_position = calculate_global_position(direction,global_position)
	if new_position:
		global_position = new_position
		return true
	return false
func calculate_global_position(direction: Vector2, starting_global_position:Vector2):
	#TODO check kolusi dengan balok lain
	if is_colliding_with_other_tetromino(direction, starting_global_position):
		return null
	#todo kolui dengan tembok
	if !is_within_game_bounds(direction, starting_global_position):
		return null
	return starting_global_position + direction * pieces[0].get_size().x
func is_within_game_bounds(direction: Vector2, starting_global_position):
	for piece in pieces:
		var new_position = piece.position + starting_global_position + direction * piece.get_size()
		if new_position.x < bounds.get("min_x") || new_position.x > bounds.get("max_x") || new_position.y >= bounds.get("max_y"):
			return false
	return true
func is_colliding_with_other_tetromino(direction:  Vector2, starting_global_position: Vector2):
	for tetromino in other_tetrominos:
		var tetromino_pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for tetromino_piece in tetromino_pieces:
			for piece in pieces:
				if starting_global_position + piece.position + direction * piece.get_size().x == tetromino.global_position + tetromino_piece.position:
					return true
	return false
func rotate_tetromino(direction: int):
	var  original_rotation_index = rotation_index
	if tetromino_data.tetromino_type == Shared.Tetromino.O:
		return
	
	apply_rotation(direction)
	rotation_index = wrap(rotation_index + direction,0,4) 
	
	if !test_wall_kicks(rotation_index, direction):
		rotation_index = original_rotation_index
		apply_rotation(-direction)
	
func test_wall_kicks(rotation_index: int, rotation_direction: int):
	var wall_kick_index = get_wall_kick_index(rotation_index,rotation_direction)
	for i in wall_kicks[0].size():
		var translation = wall_kicks[wall_kick_index][i]
		if move(translation):
			return true
	return false

func get_wall_kick_index(rotation_index:int,rotation_direction):
	var walk_kick_index = rotation_index * 2
	if rotation_direction<0:
		walk_kick_index -=1
	return wrap(walk_kick_index, 0 , wall_kicks.size())

func apply_rotation(direction: int):
	var rotation_matrix = Shared.clockwise_rotation_matrix if direction == 1 else Shared.counter_clockwise_rotation_matrix
	
	var tetromino_cells = Shared.cells[tetromino_data.tetromino_type]
	
	for i in tetromino_cells.size():
		var cell =  tetromino_cells[i]
		var x
		var y
		var coordinates = rotation_matrix[0] * cell.x + rotation_matrix[1] * cell.y
		tetromino_cells[i] = coordinates
	
	for i in pieces.size():
		var piece = pieces[i]
		piece.position = tetromino_cells[i] * piece.get_size()
func hard_drop():
	#ini blok turun cepat
	set_process_input(false)
	while move(Vector2.DOWN):
		await get_tree().create_timer(hard_drop_speed).timeout
	lock()
func _physics_process(delta):
	if is_next_piece:
		return
	
	if follow_player and player and not auto_hard_dropped:
		follow_timer_step += delta
		follow_timer += delta
		if follow_timer_step >= follow_interval:
			follow_timer_step = 0
			follow_player_logic(delta)
			if follow_timer >= follow_duration:
				auto_hard_dropped = true
				hard_drop()
		
func follow_player_logic(delta):
	var dir = player.global_position.x - global_position.x
	
	if abs(dir) > 20:
		var move_dir = sign(dir)
		move(Vector2(move_dir, 0))

func lock():
	timer.stop()
	lock_tetromino.emit(self)
	set_process_input(false)
func _on_timer_timeout() -> void:
	var should_lock = !move(Vector2.DOWN)
	if should_lock:
		lock()
