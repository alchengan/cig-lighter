class_name Cigarette
extends Area3D

@onready var lit_particles := $GPUParticles3D

var is_lit: bool = false

@onready var light_sound := $CigLightSound

func _process(delta: float) -> void:
	lit_particles.emitting = is_lit

func ignite() -> void:
	if is_lit:
		return

	is_lit = true
	light_sound.play()

	print("Cigarette lit")


func _on_car_reset_car() -> void:
	is_lit = false
