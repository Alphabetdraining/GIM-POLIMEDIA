extends Node2D

@export var flashbang_scene: PackedScene
@export var spawn_area_min: Vector2
@export var spawn_area_max: Vector2
@export var spawn_interval := 2.5

var timer := 0.0

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		timer = 0.0
		spawn_flashbang()

func spawn_flashbang():
	if not flashbang_scene:
		return

	var flashbang = flashbang_scene.instantiate()
	var x = randf_range(spawn_area_min.x, spawn_area_max.x)
	var y = randf_range(spawn_area_min.y, spawn_area_max.y)

	flashbang.global_position = Vector2(x, y)
	get_parent().add_child(flashbang)
