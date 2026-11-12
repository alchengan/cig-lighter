extends RigidBody3D

@onready var match_head := $Head

var is_lit := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match_head.area_entered.connect(_on_match_head_area_entered)

func _on_match_head_area_entered(area: Area3D) -> void:
	if is_lit:
		return

	if area is Striker:
		if area.get_strike_velocity().length() >= area.min_strike_speed:
			ignite()


func ignite() -> void:
	if is_lit:
		return

	is_lit = true

	print("Match ignited")
