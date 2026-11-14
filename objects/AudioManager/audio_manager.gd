extends Node

@onready var music_player := $MusicPlayer

func play_music(music: AudioStream) -> void:
	if music_player.playing:
		return

	music_player.stream = music
	music_player.play()

func stop_music() -> void:
	music_player.stop()
