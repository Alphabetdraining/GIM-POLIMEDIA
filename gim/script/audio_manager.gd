extends Node

@onready var music_player: AudioStreamPlayer = $MusicPlayer

func play_music(new_stream: AudioStream):
	if music_player.stream == new_stream:
		return
	
	music_player.stream = new_stream
	music_player.play()

func stop_music():
	music_player.stop()
	music_player.stream = null
