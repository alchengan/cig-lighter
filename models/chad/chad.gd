extends Node3D

@export var chad_pos_start: Vector3
@export var chad_pos_final: Vector3
@export var stick_out_time := 1.0 #s

var stick_out := false
var sticking_out_time := 0.0 

func _process(delta):
	if stick_out and sticking_out_time < stick_out_time:
		sticking_out_time += delta
		
	position = lerp(chad_pos_start, chad_pos_final, clampf(sticking_out_time / stick_out_time, 0.0, 1.0))

func _on_match_match_lit() -> void:
	stick_out = true


func _on_car_reset_car() -> void:
	stick_out = false
	sticking_out_time = 0.0
