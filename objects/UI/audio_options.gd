extends Control

@onready var master_slider := $VBoxContainer/MasterSlider
@onready var music_slider := $VBoxContainer/MusicSlider
@onready var sfx_slider := $VBoxContainer/SFXSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	master_slider.value = get_bus_volume("Master")
	music_slider.value = get_bus_volume("Music")
	sfx_slider.value = get_bus_volume("Sfx")
	
	master_slider.value_changed.connect(_on_master_changed)
	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)

func get_bus_volume(bus_name: String) -> float:
	var index := AudioServer.get_bus_index(bus_name)

	if AudioServer.is_bus_mute(index):
		return 0.0

	return db_to_linear(AudioServer.get_bus_volume_db(index))


func set_bus_volume(bus_name: String, volume: float) -> void:
	var index := AudioServer.get_bus_index(bus_name)

	AudioServer.set_bus_mute(index, volume <= 0.0)

	if volume > 0.0:
		AudioServer.set_bus_volume_db(index, linear_to_db(volume))

func _on_master_changed(value: float) -> void:
	set_bus_volume("Master", value)

func _on_music_changed(value: float) -> void:
	set_bus_volume("Music", value)

func _on_sfx_changed(value: float) -> void:
	set_bus_volume("Sfx", value)

func apply_settings() -> void:
	set_bus_volume("Master", master_slider.value)
	set_bus_volume("Music", music_slider.value)
	set_bus_volume("Sfx", sfx_slider.value)
