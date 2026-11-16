class_name Cigarette
extends Area3D

signal cigarette_lit

@onready var lit_particles := $GPUParticles3D
@onready var light_sound := $CigLightSound

var is_lit: bool = false

func _ready() -> void:
	cigarette_lit.connect(RunTimer.cigarette_lit)

func _process(delta: float) -> void:
	lit_particles.emitting = is_lit

func ignite() -> void:
	if is_lit:
		return

	is_lit = true
	light_sound.play()
	cigarette_lit.emit()

	print("Cigarette lit")


func _on_car_reset_car() -> void:
	is_lit = false
