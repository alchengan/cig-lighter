extends RigidBody3D

@export_group("Movement")
@export var gas_acceleration := 15.0 # m/s/s
@export var max_speed := 60 # m/s
@export var normal_deceleration := 10.0 # m/s/s
@export var brake_deceleration := 25.0 # m/s/s
@export var x_deceleration := 50.0 # m/s/s
@export var max_turn_speed := 15.0 # degrees
@export var turn_accel := 15.0 # degrees/s
@export var reset_turn_accel := 30.0 # degrees/s

@export_group("Input Actions")
@export var turn_left := "turn_left"
@export var turn_right := "turn_right"
@export var gas := "gas"
@export var brake := "brake"
@export var drift := "drift"
@export var reverse:= "reverse"

var forward_speed := 0.0
var turn_speed := 0.0

func _ready() -> void:
	check_input_mappings()
	axis_lock_angular_x = true
	axis_lock_angular_z = true
	
func _physics_process(delta: float) -> void:
	drive(delta)
	
func _integrate_forces(state: PhysicsDirectBodyState3D) -> void:
	# decelerate any lateral velocity to 0, see drive() comments
	var local_velocity_x := linear_velocity.dot(global_transform.basis.x)
	var speed_diff := 0 - local_velocity_x
	var velocity_delta := move_toward(local_velocity_x, 0, x_deceleration * state.step) - local_velocity_x
	var x_acceleration := velocity_delta / state.step
	apply_force(mass * x_acceleration * global_transform.basis.x.normalized())

	#state.linear_velocity.x = move_toward(state.linear_velocity.y, 0.0, x_deceleration * state.step)
	
	# turn
	var turn_accel_rate: float
	var target_turn_speed := Input.get_axis(turn_right, turn_left) * max_turn_speed * (-1 if linear_velocity.dot(transform.basis.z) < 0 else 1)
	var angular_speed_diff := target_turn_speed - angular_velocity.y
	
	if absf(angular_speed_diff) > max_turn_speed or target_turn_speed == 0:
		turn_accel_rate = reset_turn_accel
	else:
		turn_accel_rate = turn_accel
	
	if linear_velocity.length() > 0.01:
		state.angular_velocity.y = move_toward(state.angular_velocity.y, target_turn_speed, turn_accel_rate * state.step)
	else:
		state.angular_velocity.y = move_toward(state.angular_velocity.y, 0, reset_turn_accel * state.step)
	
# forward and backward movement
# mass dependent
func drive(delta: float) -> void:
	var target_speed : float
	var accel_rate : float
	
	# brake overrides all
	if Input.is_action_pressed(gas) and not Input.is_action_pressed(brake):
		if Input.is_action_pressed(reverse):
			target_speed = -max_speed
		else:
			target_speed = max_speed
	else:
		#print("go 0")
		target_speed = 0.0
		
	if absf(target_speed) > 0.01:
		accel_rate = gas_acceleration
	elif Input.is_action_pressed(brake):
		#print("brake????")
		accel_rate = brake_deceleration
	else:
		accel_rate = normal_deceleration
		
	# calculate difference between current velocity and desired velocity
	var local_velocity_z := linear_velocity.dot(global_transform.basis.z)
	var speed_diff := target_speed - local_velocity_z
	# calculate force along local z-axis to apply to car
	var velocity_delta := move_toward(local_velocity_z, target_speed, accel_rate * delta) - local_velocity_z
	var acceleration := velocity_delta / delta
	# f = ma
	apply_force(mass * acceleration * global_transform.basis.z.normalized())
	print(linear_velocity.length())
	
#func turn(delta: float) -> void:
	
	#var target_turn_speed := 0.0
	#var turn_accel_rate: float
	#
	## if both are pressed down, cancel each other out
	#if (Input.is_action_pressed(turn_left)): 
		#target_turn_speed += max_turn_speed
	#if (Input.is_action_pressed(turn_right)): 
		#target_turn_speed -= max_turn_speed
		#
	## calculate difference between current angular velocity and desired angular velocity
	#var angular_speed_diff := target_turn_speed - angular_velocity.y
	#
	#if absf(angular_speed_diff) > max_turn_speed or target_turn_speed == 0:
		#turn_accel_rate = reset_turn_accel
	#else:
		#turn_accel_rate = turn_accel
	#
	## calculate angular force around y-axis to apply to car
	#var turn_force := angular_speed_diff * turn_accel_rate
	#
	#if (linear_velocity.length() > 0.01):
		#apply_torque(turn_force * Vector3.UP)

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
	
