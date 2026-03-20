extends Node3D

@export var building_scene: PackedScene
@export var lanes_x: int = 6
@export var lane_spacing: float = 8.0
@export var min_height: float = 10.0
@export var max_height: float = 40.0
@export var row_spacing: float = 30.0
@export var spawn_distance_ahead: float = 200.0
@export var cleanup_distance_behind: float = 50.0
@export var empty_lane_probability: float = 0.25

var _last_spawn_z: float = 0.0
var _player: Node3D
var _buildings_root: Node3D

func _ready() -> void:
	_player = get_node_or_null("../Player")
	_buildings_root = get_node_or_null("../Buildings")
	if not building_scene:
		push_warning("Building spawner has no building_scene assigned.")

func _process(delta: float) -> void:
	if _player == null or _buildings_root == null or building_scene == null:
		return

	var player_z := _player.global_position.z

	# Spawn rows ahead of the player
	while _last_spawn_z > player_z - spawn_distance_ahead:
		_last_spawn_z -= row_spacing
		_spawn_row(_last_spawn_z)

	# Clean up buildings that are far behind the player
	for child in _buildings_root.get_children():
		if child.global_position.z > player_z + cleanup_distance_behind:
			child.queue_free()

func _spawn_row(z_pos: float) -> void:
	var half_lanes := float(lanes_x - 1) * 0.5
	for i in range(lanes_x):
		if randf() < empty_lane_probability:
			continue
			
		var x_pos := (float(i) - half_lanes) * lane_spacing
		var building := building_scene.instantiate()
		if building is Node3D:
			_buildings_root.add_child(building)
			building.global_position = Vector3(x_pos, 0.0, z_pos)
			if "height" in building:
				building.height = randf_range(min_height, max_height)
