extends Node

@export var player_path: NodePath
@export var score_label_path: NodePath
@export var game_over_root_path: NodePath

var _player: Node
var _score_label: Label
var _game_over_root: CanvasItem
var _running: bool = true
var _score_time: float = 0.0

func _ready() -> void:
	_player = get_node_or_null(player_path)
	_score_label = get_node_or_null(score_label_path)
	_game_over_root = get_node_or_null(game_over_root_path)

	if _game_over_root:
		_game_over_root.visible = false

func _process(delta: float) -> void:
	if not _running:
		return
	_score_time += delta
	if _score_label:
		_score_label.text = "Score: " + str(int(_score_time * 10.0))

func on_player_died() -> void:
	if not _running:
		return
	_running = false
	if _game_over_root:
		_game_over_root.visible = true

func restart() -> void:
	get_tree().reload_current_scene()
