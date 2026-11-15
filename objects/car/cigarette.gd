class_name Cigarette
extends Area3D

var is_lit: bool = false

func ignite() -> void:
	if is_lit:
		return

	is_lit = true

	print("Cigarette lit")


func _on_car_reset_car() -> void:
	is_lit = false
