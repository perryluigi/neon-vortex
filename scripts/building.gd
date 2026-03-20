extends StaticBody3D

@export var height: float = 20.0:
	set(value):
		height = max(1.0, value)
		_update_height()

func _ready() -> void:
	_update_height()

func _update_height() -> void:
	var mesh_instance := $MeshInstance3D if has_node("MeshInstance3D") else null
	var collision_shape := $CollisionShape3D if has_node("CollisionShape3D") else null
	if mesh_instance and mesh_instance.mesh is BoxMesh:
		var box: BoxMesh = mesh_instance.mesh
		box.size.y = height
		mesh_instance.mesh = box
		mesh_instance.position.y = height * 0.5
	if collision_shape and collision_shape.shape is BoxShape3D:
		var shape: BoxShape3D = collision_shape.shape
		shape.size.y = height
		collision_shape.shape = shape
		collision_shape.position.y = height * 0.5
