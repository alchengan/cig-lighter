extends Node2D

@export var on_color: Color
@export var off_color: Color
@export var reverse_button_on_pos: Vector2
@export var reverse_button_off_pos: Vector2

@onready var gas_pedal := $GasPedal
@onready var brake := $Brake
@onready var drift := $Drift
@onready var reverse := $Reverse
@onready var reverse_sprite := $Reverse/Sprite
@onready var reverse_button := $Reverse/RichTextLabel2

func _process(_delta: float) -> void:
	if Input.is_action_pressed("gas"):
		gas_pedal.modulate = on_color
	else:
		gas_pedal.modulate = off_color
		
	if Input.is_action_pressed("brake"):
		brake.modulate = on_color
	else:
		brake.modulate = off_color
		
	if Input.is_action_pressed("drift"):
		drift.modulate = on_color
	else:
		drift.modulate = off_color
		
	if Input.is_action_pressed("reverse"):
		reverse.modulate = on_color
		reverse_sprite.rotation_degrees = 180.0
		reverse_button.position = reverse_button_on_pos
	else:
		reverse.modulate = off_color
		reverse_sprite.rotation_degrees = 0.0
		reverse_button.position = reverse_button_off_pos
		
