extends Area2D
class_name Powerup

enum PowerupType {
	DOUBLE_JUMP,
	SPEED_BOOST,
	INVINCIBLE
}

var powerup_type: PowerupType
var lifetime = 10.0

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D

func _ready():
	powerup_type = PowerupType.values().pick_random()
	Set_Powerup_Visual()
	body_entered.connect(_on_body_entered)

func _process(delta):
	lifetime -= delta
	if lifetime <= 0:
		queue_free()
	position.y += 50 * delta

func Set_Powerup_Visual():
	modulate = Color.YELLOW if powerup_type == PowerupType.DOUBLE_JUMP else Color.CYAN

func _on_body_entered(body):
	if body.name == "Player":
		Apply_Powerup(body)
		queue_free()

func Apply_Powerup(player):
	match powerup_type:
		PowerupType.DOUBLE_JUMP:
			player.used_jumps = player.MAX_JUMPS
		PowerupType.SPEED_BOOST:
			print("Speed boost activated!")
		PowerupType.INVINCIBLE:
			player.is_invulnerable = true
			player.invulnerable_timer = 3.0
