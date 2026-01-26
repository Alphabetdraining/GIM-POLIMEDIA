extends CharacterBody2D

signal hp_changed(new_hp)
signal player_died

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

const MAX_HP = 3
var hp = MAX_HP
var is_invulnerable = false
var invulnerable_timer = 0.0
const INVULNERABLE_TIME = 1.5

const POWERUP_2_ACTION = "powerup_2"

const TELEPORT_COOLDOWN = 3.0
var teleport_cooldown_timer = 0.0

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var used_jumps = MAX_JUMPS

const MIN_X = -870
const MAX_X = 890

var is_dead = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hit_detector = $HitDetector

func _physics_process(delta):
	if is_dead:
		return

	if teleport_cooldown_timer > 0:
		teleport_cooldown_timer -= delta

	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			is_invulnerable = false
			modulate.a = 1.0
		else:
			modulate.a = 0.5 if fmod(invulnerable_timer * 10, 2) < 1 else 1.0

	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		used_jumps = MAX_JUMPS

	if Input.is_action_just_pressed("jump") and used_jumps > 0:
		velocity.y = JUMP_VELOCITY
		used_jumps -= 1

	var direction = Input.get_axis("move_left", "move_right")
	if direction != 0:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true

	if Input.is_action_just_pressed(POWERUP_2_ACTION) and teleport_cooldown_timer <= 0:
		teleport_to_safe_position()
		teleport_cooldown_timer = TELEPORT_COOLDOWN

	if is_on_floor():
		if abs(velocity.x) < 1:
			play_animation("idle")
		else:
			play_animation("run")
	else:
		play_animation("jump")

	move_and_slide()
	global_position.x = clamp(global_position.x, MIN_X, MAX_X)

func teleport_to_safe_position():
	var board = get_node_or_null("/root/Main/board")
	if not board:
		return

	var highest_block_y = get_highest_block_y()
	var target_y = highest_block_y - 58
	var target_pos = Vector2(global_position.x, target_y)

	if is_position_safe(target_pos, board):
		global_position = target_pos
	else:
		respawn_to_safe_position()

func get_highest_block_y() -> float:
	var board = get_node_or_null("/root/Main/board")
	if not board:
		return global_position.y

	var highest_y = null

	for tetromino in board.tetrominos:
		var pieces = tetromino.get_children().filter(func(c): return c is Piece)
		for piece in pieces:
			var y = tetromino.global_position.y + piece.position.y
			if highest_y == null or y < highest_y:
				highest_y = y

	if highest_y == null:
		return global_position.y

	return highest_y

func take_damage(amount := 1):
	if is_dead or is_invulnerable:
		return

	hp -= amount
	hp = max(hp, 0)
	print("Player HP:", hp)
	hp_changed.emit(hp)

	if hp == 0:
		die()
	else:
		respawn_to_safe_position()
		is_invulnerable = true
		invulnerable_timer = INVULNERABLE_TIME

func die():
	is_dead = true
	print("You died!")
	player_died.emit()
	Engine.time_scale = 0.5
	collision_shape.queue_free()
	await get_tree().create_timer(0.5).timeout
	Engine.time_scale = 1.0
	get_tree().reload_current_scene()

func respawn_to_safe_position():
	var safe_positions = find_safe_positions()
	if safe_positions.size() > 0:
		global_position = safe_positions[0]
	else:
		global_position = Vector2(-16, 480)

func find_safe_positions() -> Array:
	var safe_positions = []
	var board = get_node_or_null("/root/Main/board")
	if not board:
		return [Vector2(-16, 480)]
	
	for x in range(-4, 5):
		for y in range(-9, 10):
			var test_pos = Vector2(x * 58, y * 58)
			if is_position_safe(test_pos, board):
				safe_positions.append(test_pos)
	
	return safe_positions

func is_position_safe(pos: Vector2, board) -> bool:
	for tetromino in board.tetrominos:
		var pieces = tetromino.get_children().filter(func (c): return c is Piece)
		for piece in pieces:
			var piece_pos = tetromino.global_position + piece.position
			if pos.distance_to(piece_pos) < 30:
				return false
	return true

func play_animation(base_anim: String):
	match hp:
		3:
			animated_sprite.play(base_anim)
		2:
			animated_sprite.play(base_anim + "_hurt")
		1:
			animated_sprite.play(base_anim + "_critical")

func _on_hit_detector_area_entered(area):
	if area is Piece and not is_invulnerable:
		take_damage(1)
