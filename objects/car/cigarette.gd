class_name Cigarette
extends Area3D

var is_lit: bool = false

func ignite() -> void:
	if is_lit:
		return

	is_lit = true

	print("Cigarette lit")
