extends Control

var paused = false
#@onready var click = $click

func _ready() -> void:
	visible = false
	process_mode = Node.PROCESS_MODE_ALWAYS

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		#click.play() 
		if not paused:
			paused = true
			visible = true
			get_tree().paused = true
		else:
			paused = false
			visible = false
			get_tree().paused = false

func _on_continue_button_down():
	#click.play()
	#await click.finished
	paused = false
	visible = false
	get_tree().paused = false

func _on_restart_button_down():
	paused = false
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_quit_button_down():
	get_tree().quit()
