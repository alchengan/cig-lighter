extends RigidBody3D

@export_group("Movement")
@export var gas_acceleration := 15.0 # m/s/s
@export var max_speed := 60.0 # m/s
@export var normal_deceleration := 10.0 # m/s/s
@export var brake_deceleration := 25.0 # m/s/s
@export var x_deceleration := 50.0 # m/s/s
@export var max_turn_speed := 0.5 # radians/s
@export var turn_accel := 0.5 # radians/s/s
@export var reset_turn_accel := 3.0 # radians/s/s

@export_group("Drift")
@export var drift_acceleration := 10.0 # m/s/s
@export var drift_max_speed := 30.0 # m/s
@export var drift_normal_deceleration := 10.0 # m/s/s
@export var drift_brake_deceleration := 20.0 # m/s/s
@export var drift_max_turn_speed := 1.0 # radians/s
@export var drift_turn_accel := 1.0 # radians/s/s
@export var drift_reset_turn_accel := 3.0 # radians/s/s
@export var drift_car_angle := 1.0 # radians
@export var drift_car_spin_speed := 8.0 # radians/s 

@export_group("Wheel Stuff")
@export var wheel_radius := 0.2 # m
@export var wheel_turn_angle := 0.5 # radians
@export var wheel_turn_speed := 4.0 # radians

@export_group("Input Actions")
@export var turn_left := "turn_left"
@export var turn_right := "turn_right"
@export var gas := "gas"
@export var brake := "brake"
@export var drift := "drift"
@export var reverse:= "reverse"

@onready var mesh_shape := $"86Parent"
@onready var collision_shape := $CollisionShape3D
@onready var cig := $"Cigarette"
@onready var spoiler := $Striker

# wheels
@onready var wheel_fr := $"86Parent/86/WheelFrontRightParent/WheelParent/Wheel"
@onready var wheel_fl := $"86Parent/86/WheelFrontLeftParent/WheelParent/Wheel"
@onready var wheel_br := $"86Parent/86/WheelBackRight/Wheel"
@onready var wheel_bl := $"86Parent/86/WheelBackLeft/Wheel"
@onready var wheel_parent_fr := $"86Parent/86/WheelFrontRightParent"
@onready var wheel_parent_fl := $"86Parent/86/WheelFrontLeftParent"

signal start_drifting
signal stop_drifting

var forward_speed := 0.0
var turn_speed := 0.0

var curr_car_angle := 0.0
var curr_wheel_angle := 0.0

func _ready() -> void:
	check_input_mappings()
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	
func _process(delta: float) -> void:
	wheel_roll(delta)
	wheel_turn(delta)
	drift_car_turn(delta)
	
	if Input.is_action_just_pressed(drift): start_drifting.emit()
	if Input.is_action_just_released(drift): stop_drifting.emit()
		
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	drive(state.step)
	lateral_decel(state.step)
	
	state.angular_velocity.y = turn(state.angular_velocity.y, state.step)
	#print(state.angular_velocity.y)

func drive(delta: float) -> void:
	# forward and backward movement
	# mass dependent
	
	var drifting := Input.is_action_pressed(drift) and Input.is_action_pressed(reverse)
	var _gas_acceleration := drift_acceleration if drifting else gas_acceleration
	var _max_speed := drift_max_speed if drifting else max_speed
	var _brake_deceleration := drift_brake_deceleration if drifting else brake_deceleration
	var _normal_deceleration := drift_normal_deceleration if drifting else normal_deceleration
	
	var target_speed : float
	var accel_rate : float
	
	# brake overrides all
	if Input.is_action_pressed(gas) and not Input.is_action_pressed(brake):
		if Input.is_action_pressed(reverse):
			target_speed = -_max_speed
		else:
			target_speed = _max_speed
	else:
		#print("go 0")
		target_speed = 0.0
		
	if absf(target_speed) > 0.01:
		accel_rate = _gas_acceleration
	elif Input.is_action_pressed(brake):
		#print("brake????")
		accel_rate = _brake_deceleration
	else:
		accel_rate = _normal_deceleration
		
	# calculate difference between current velocity and desired velocity
	var local_velocity_z := linear_velocity.dot(global_transform.basis.z)
	# calculate force along local z-axis to apply to car
	var velocity_delta := move_toward(local_velocity_z, target_speed, accel_rate * delta) - local_velocity_z
	var acceleration := velocity_delta / delta
	# f = ma
	apply_force(mass * acceleration * global_transform.basis.z.normalized())
	#print(linear_velocity.length())
	
	
func lateral_decel(delta: float) -> void:
	# decelerate any lateral velocity to 0, see drive() comments
	var local_velocity_x := linear_velocity.dot(global_transform.basis.x)
	var velocity_delta := move_toward(local_velocity_x, 0, x_deceleration * delta) - local_velocity_x
	var x_acceleration := velocity_delta / delta
	apply_force(mass * x_acceleration * global_transform.basis.x.normalized())
	
	
func turn(curr_turn_speed: float, delta: float) -> float:
	var drifting := Input.is_action_pressed(drift) and Input.is_action_pressed(reverse)
	var _max_turn_speed := drift_max_turn_speed if drifting else max_turn_speed
	var _turn_accel := drift_turn_accel if drifting else turn_accel
	var _reset_turn_accel := drift_reset_turn_accel if drifting else reset_turn_accel
	
	var turn_accel_rate: float
	var target_turn_speed := Input.get_axis(turn_right, turn_left) * _max_turn_speed * (-1 if linear_velocity.dot(transform.basis.z) < 0 else 1)
	var angular_speed_diff := target_turn_speed - curr_turn_speed
	
	if absf(angular_speed_diff) > _max_turn_speed or target_turn_speed == 0:
		turn_accel_rate = _reset_turn_accel
	else:
		turn_accel_rate = _turn_accel
		
	if linear_velocity.length() > 0.01:
		return move_toward(curr_turn_speed, target_turn_speed, turn_accel_rate * delta)
		
	return move_toward(curr_turn_speed, 0, _reset_turn_accel * delta)
	
	
func drift_car_turn(delta: float) -> void:
	var turn_dir := Input.get_axis(turn_right, turn_left)
	var target_car_angle : float
	
	if (Input.is_action_pressed(drift)):
		if turn_dir < 0:
			target_car_angle = -drift_car_angle
		elif turn_dir > 0:
			target_car_angle = drift_car_angle
		else:
			target_car_angle = 0
	else:
		target_car_angle = 0
		
	curr_car_angle = move_toward(curr_car_angle, target_car_angle, drift_car_spin_speed * delta)
	mesh_shape.rotation = Vector3(0, curr_car_angle, 0)
	collision_shape.rotation = Vector3(0, curr_car_angle, 0)
	cig.rotation = Vector3(0, curr_car_angle, 0)
	spoiler.rotation = Vector3(0, curr_car_angle, 0)
	
func wheel_roll(delta: float) -> void:
	var wheel_angular_velocity := linear_velocity.length() / wheel_radius * (-1 if linear_velocity.dot(transform.basis.z) < 0 else 1)
	wheel_fl.rotate_z(wheel_angular_velocity * delta)
	wheel_bl.rotate_z(wheel_angular_velocity * delta)
	wheel_fr.rotate_z(-wheel_angular_velocity * delta)
	wheel_br.rotate_z(-wheel_angular_velocity * delta)
	
func wheel_turn(delta: float) -> void:
	var turn_dir := Input.get_axis(turn_right, turn_left)
	var target_wheel_angle := turn_dir * wheel_turn_angle
	
	curr_wheel_angle = move_toward(curr_wheel_angle, target_wheel_angle, wheel_turn_speed * delta)
	wheel_parent_fl.rotation = Vector3(0, curr_wheel_angle, 0)
	wheel_parent_fr.rotation = Vector3(0, curr_wheel_angle, 0)
	
func check_input_mappings():
	if not InputMap.has_action(turn_left):
		push_error("Movement disabled. No InputAction found for turn_left: " + turn_left)
	if not InputMap.has_action(turn_right):
		push_error("Movement disabled. No InputAction found for turn_right: " + turn_right)
	if not InputMap.has_action(gas):
		push_error("Movement disabled. No InputAction found for gas: " + gas)
	if not InputMap.has_action(brake):
		push_error("Movement disabled. No InputAction found for brake: " + brake)
	if not InputMap.has_action(drift):
		push_error("Movement disabled. No InputAction found for turn_left: " + drift)
	if not InputMap.has_action(reverse):
		push_error("Movement disabled. No InputAction found for reverse: " + reverse)
	
