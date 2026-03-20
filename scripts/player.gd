extends CharacterBody3D

@export var forward_speed: float = 20.0
@export var strafe_speed: float = 15.0
@export var vertical_speed: float = 15.0

var alive: bool = true

func _physics_process(delta: float) -> void:
	if not alive:
		velocity = Vector3.ZERO
		move_and_slide()
		return

	# Constant forward motion along -Z (into the city)
	velocity.z = -forward_speed

	# Horizontal (X) and vertical (Y) movement via WASD
	var input_dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("move_left"):
		input_dir.x -= 1.0
	if Input.is_action_pressed("move_right"):
		input_dir.x += 1.0
	if Input.is_action_pressed("move_up"):
		input_dir.y += 1.0
	if Input.is_action_pressed("move_down"):
		input_dir.y -= 1.0

	input_dir = input_dir.normalized()

	velocity.x = input_dir.x * strafe_speed
	velocity.y = input_dir.y * vertical_speed

	move_and_slide()

func die() -> void:
	alive = false
