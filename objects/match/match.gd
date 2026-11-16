extends RigidBody3D

@onready var match_head := $Head
@onready var light_sound := $LightSound
@onready var light_particles := $Light

@export var is_lit := false

signal match_lit

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_head.area_entered.connect(_on_match_head_area_entered)
	
func _process(_delta) -> void:
	light_particles.emitting = is_lit

func _on_match_head_area_entered(area: Area3D) -> void:
	if area is Striker:
		if area.get_strike_velocity().length() >= area.min_strike_speed:
			ignite()
	elif area is Cigarette:
		#print("Cig entered")
		if is_lit:
			area.ignite() # light the cig


func ignite() -> void:
	if is_lit:
		return

	is_lit = true
	light_sound.play()
	match_lit.emit()
	print("Match ignited")


func _on_car_reset_car() -> void:
	is_lit = false
