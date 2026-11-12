class_name Striker
extends Area3D

@export var min_strike_speed := 30.0 # m/s
@export var car: RigidBody3D

func get_strike_velocity() -> Vector3:
	if car == null:
		return Vector3.ZERO

	var offset := global_position - car.global_position

	return car.linear_velocity + car.angular_velocity.cross(offset)
