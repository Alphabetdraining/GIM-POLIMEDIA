extends ScrollContainer

@export var scroll_speed: float = 120.0
@export var acceleration: float = 5.0 # untuk mempercepat scroll saat ditekan

var manual_scroll: bool = false
var auto_scroll_enabled: bool = true

@onready var v_scroll = get_v_scroll_bar()

func _ready() -> void:
	#mulai dari paling atas
	scroll_vertical = 0
	
	#mouse detection
	v_scroll.gui_input.connect(_on_scrollbar_input)
	
func _process(delta: float) -> void:
	if not auto_scroll_enabled: return
	
	#hitung kecepatan
	var current_speed = scroll_speed
	if Input.is_action_pressed("ui_accept") or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		current_speed *= acceleration
		
	#tambah posisi scroll secara bertahap
	var new_scroll = scroll_vertical + (current_speed * delta)
	
	#set posisi scroll
	scroll_vertical = int(new_scroll)
	
	#cek apakah sudah sampai akhir
	if scroll_vertical + size.y >= v_scroll.max_value:
		_on_finished()
	
func _on_scrollbar_input(event: InputEvent) -> void:
		#jika user scroll pake wheel atau drag scrollbar, sinkronisasi agar tidak "lompat"
	if event is InputEventMouseButton:
		pass	
			
func _on_finished() -> void:
	auto_scroll_enabled = false
	print("kredit berhasil")
