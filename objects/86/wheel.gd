extends Node3D

@export var material: ORMMaterial3D
@export var car: RigidBody3D
@export var skidmark_parent: Node3D
@export var wheel_bottom: Node3D
@export var skidmark_half_width: float # m
@export var speed_threshhold: float # m/s
@export var flipped: bool

var mesh_instance: MeshInstance3D
var immediate_mesh: ImmediateMesh
var drifting: bool
var mesh_vertices: Array[Vector3]

func _ready() -> void:
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	print(skidmark_parent)
	
func _process(delta) -> void:
	if skidmark_parent == null:
		return
		
	if drifting:
		var _skidmark_half_width = lerpf(0, skidmark_half_width, clamp(car.linear_velocity.length() / speed_threshhold, 0.0, 1.0))
		var new_front_drift_point: Vector3 = wheel_bottom.global_position + car.global_basis.x * _skidmark_half_width
		var new_back_drift_point: Vector3 = wheel_bottom.global_position - car.global_basis.x * _skidmark_half_width

		mesh_vertices.append(Vector3(new_front_drift_point.x, 0.01, new_front_drift_point.z))
		mesh_vertices.append(Vector3(new_back_drift_point.x, 0.01, new_back_drift_point.z))
		
		immediate_mesh.clear_surfaces()
		immediate_mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLE_STRIP, material)
		for v in mesh_vertices:
			immediate_mesh.surface_add_vertex(v)
		immediate_mesh.surface_end()
		
func _on_car_start_drifting() -> void:
	#print("drift started")
	if skidmark_parent == null:
		return
		
	drifting = true
	
	mesh_instance = MeshInstance3D.new()
	immediate_mesh = ImmediateMesh.new()
	
	mesh_instance.mesh = immediate_mesh
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	skidmark_parent.add_child(mesh_instance)
	
	mesh_vertices = [Vector3(wheel_bottom.global_position.x, 0.01, wheel_bottom.global_position.z), 
					 Vector3(wheel_bottom.global_position.x, 0.01, wheel_bottom.global_position.z), 
					 Vector3(wheel_bottom.global_position.x, 0.01, wheel_bottom.global_position.z)]
	
func _on_car_stop_drifting() -> void:
	drifting = false
