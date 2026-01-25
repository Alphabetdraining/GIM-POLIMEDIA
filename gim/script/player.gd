extends CharacterBody2D

const SPEED = 130.0
const JUMP_VELOCITY = -300.0
const MAX_JUMPS = 2

const DASH_SPEED = 400.0
const DASH_TIME = 0.15
const DASH_COOLDOWN = 2.0

const MAX_HP = 3
var hp = MAX_HP

const POWERUP_1_ACTION = "powerup_1"
const POWERUP_2_ACTION = "powerup_2"

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var used_jumps = MAX_JUMPS

var is_dashing = false
var dash_timer = 0.0
var dash_direction = 0
var dash_cooldown_timer = 0.0
var is_dead = false

@onready var animated_sprite = $AnimatedSprite2D
@onready var collision_shape = $CollisionShape2D

func _physics_process(delta):
	if is_dead:
		return

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

func take_damage(amount := 1):
	if is_dead:
		return

	hp -= amount
	hp = max(hp, 0)
	print("Player HP:", hp)

	if hp == 0:
		die()

func die():
	is_dead = true
	print("You died!")
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
			animated_sprite.play(base_anim) #+ "_hurt")
		1:
			animated_sprite.play(base_anim) #+ "_critical")
		#_:
			#animated_sprite.play(base_anim + "_critical")

func start_dash():
	is_dashing = true
	dash_timer = DASH_TIME

	dash_direction = sign(Input.get_axis("move_left", "move_right"))
	if dash_direction == 0:
		dash_direction = sign(velocity.x)
		if dash_direction == 0:
			dash_direction = 1
