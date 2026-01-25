extends CharacterBody2D

signal hp_changed(new_hp)
signal player_died

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

const DASH_SPEED = 400.0
const DASH_TIME = 0.15
const DASH_COOLDOWN = 2.0

const MAX_HP = 3
var hp = MAX_HP
var is_invulnerable = false
var invulnerable_timer = 0.0
const INVULNERABLE_TIME = 1.5

const POWERUP_1_ACTION = "powerup_1"
const POWERUP_2_ACTION = "powerup_2"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var used_jumps = MAX_JUMPS

const MIN_X = -262
const MAX_X = 267

var is_dashing = false
var dash_timer = 0.0
var dash_direction = 0
var dash_cooldown_timer = 0.0
var is_dead = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hit_detector = $HitDetector

func _physics_process(delta):
	if is_dead:
		return

	if is_invulnerable:
		invulnerable_timer -= delta
		if invulnerable_timer <= 0:
			is_invulnerable = false
			modulate.a = 1.0
		else:
			modulate.a = 0.5 if fmod(invulnerable_timer * 10, 2) < 1 else 1.0

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	# DASH
	if is_dashing:
		dash_timer -= delta
		velocity.x = dash_direction * DASH_SPEED
		velocity.y = 0

		if dash_timer <= 0:
			is_dashing = false
	else:
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

	if Input.is_action_just_pressed(POWERUP_1_ACTION) \
	and not is_dashing \
	and dash_cooldown_timer <= 0:
		start_dash()
		dash_cooldown_timer = DASH_COOLDOWN

	if is_on_floor():
		if abs(velocity.x) < 1:
			play_animation("idle")
		else:
			play_animation("run")
	else:
		play_animation("jump")

	move_and_slide()
	global_position.x = clamp(global_position.x, MIN_X, MAX_X)

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

func start_dash():
	is_dashing = true
	dash_timer = DASH_TIME

	dash_direction = sign(Input.get_axis("move_left", "move_right"))
	if dash_direction == 0:
		dash_direction = sign(velocity.x)
		if dash_direction == 0:
			dash_direction = 1

func _on_hit_detector_area_entered(area):
	if area is Piece and not is_invulnerable:
		take_damage(1)
