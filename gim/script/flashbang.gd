extends Area2D

@export var fall_speed = 300.0
@export var explosion_radius = 64.0
@export var stun_duration = 1.5

var exploded = false

func _physics_process(delta):
	if exploded:
		return
	position.y += fall_speed * delta

func _on_body_entered(body):
	if exploded:
		return
	explode()

func explode():
	exploded = true

	var space = get_world_2d().direct_space_state
	var shape = CircleShape2D.new()
	shape.radius = explosion_radius

	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0, global_position)
	query.collide_with_bodies = true

	var results = space.intersect_shape(query)

	for result in results:
		var collider = result.collider
		if collider.has_method("stun"):
			collider.stun(stun_duration)

	queue_free()
