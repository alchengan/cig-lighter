extends RigidBody3D

@onready var match_head := $Head
@onready var light_sound := $LightSound
@onready var fire_sound := $FireSound
@onready var light_particles := $Particles/Light
@onready var smoke_particles := $Particles/Smoke
@onready var spark_particles := $Particles/Sparks

@export var is_lit := false

signal match_lit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_head.area_entered.connect(_on_match_head_area_entered)
	match_lit.connect(RunTimer.match_lit)
	
func _on_match_head_area_entered(area: Area3D) -> void:
	if area is Striker:
		if area.get_strike_velocity().length() >= area.min_strike_speed:
			ignite(area.get_strike_velocity())
	elif area is Cigarette:
		#print("Cig entered")
		if is_lit:
			area.ignite() # light the cig


func ignite(strike_velocity: Vector3) -> void:
	if is_lit:
		return

	is_lit = true
	light_sound.play()
	fire_sound.play()
	light_particles.emitting = true
	smoke_particles.emitting = true
	spark_particles.process_material.direction = strike_velocity
	spark_particles.emitting = true
	match_lit.emit()
	print("Match ignited")


func _on_car_reset_car() -> void:
	is_lit = false

	fire_sound.stop()
	light_particles.emitting = false
