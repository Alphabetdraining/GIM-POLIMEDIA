extends CharacterBody2D

signal hp_changed(new_hp)
signal player_died

const SPEED = 500.0
const JUMP_VELOCITY = -500.0
const MAX_JUMPS = 2

const MAX_HP = 3
var hp = MAX_HP
var is_invulnerable = false
var invulnerable_timer = 0.0
const INVULNERABLE_TIME = 1.5

const POWERUP_2_ACTION = "powerup_2"

const DASH_SPEED = 900.0
const DASH_TIME = 0.20
const DASH_COOLDOWN = 3.0

var dash_timer = 0.0
var dash_cooldown_timer = 0.0
var dash_direction = Vector2.ZERO
var is_dashing = false

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var used_jumps = MAX_JUMPS

const MIN_X = -960
const MAX_X = 960

var is_dead = false

var is_stunned = false
var stun_timer = 0.0

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D
@onready var hit_detector = $HitDetector

func _physics_process(delta):
	if is_dead:
		return

	if is_stunned:
		stun_timer -= delta
		if stun_timer <= 0:
			is_stunned = false
		else:
			velocity = Vector2.ZERO
			move_and_slide()
			return

	if dash_cooldown_timer > 0:
		dash_cooldown_timer -= delta

	if is_dashing:
		dash_timer -= delta
		velocity = dash_direction * DASH_SPEED
		if dash_timer <= 0:
			is_dashing = false
	else:
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

	if Input.is_action_just_pressed(POWERUP_2_ACTION) and not is_dashing and dash_cooldown_timer <= 0:
		start_dash()

	if is_on_floor():
		if abs(velocity.x) < 1:
			play_animation("idle")
		else:
			play_animation("run")
	else:
		if animated_sprite.animation != "jump":
			play_animation("jump")

	move_and_slide()
	global_position.x = clamp(global_position.x, MIN_X, MAX_X)

func start_dash():
	var x = Input.get_axis("move_left", "move_right")
	var y = Input.get_axis("move_up", "move_down")

	if y > 0:
		y = 0

	dash_direction = Vector2(x, y)

	if dash_direction == Vector2.ZERO:
		dash_direction = Vector2(-1, 0) if animated_sprite.flip_h else Vector2(1, 0)

	dash_direction = dash_direction.normalized()

	is_dashing = true
	dash_timer = DASH_TIME
	dash_cooldown_timer = DASH_COOLDOWN
	velocity = Vector2.ZERO

func stun(duration := 1.5):
	is_stunned = true
	stun_timer = duration
	velocity = Vector2.ZERO
	
func teleport_after_damage():
	global_position.y -= 520
	velocity = Vector2.ZERO
	
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
		teleport_after_damage()
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
