extends Control

@onready var cooldown_icon = $dash/frame/cooldown
@onready var ready_icon = $dash/frame/active
@onready var player = get_node("/root/Main/Player")

func _process(_delta):
	if player.dash_cooldown_timer > 0:
		cooldown_icon.show()
		ready_icon.hide()
	else:
		cooldown_icon.hide()
		ready_icon.show()
