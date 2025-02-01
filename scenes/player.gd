extends CharacterBody3D


@export var walk_speed: float = 5.0
@export var run_speed: float = 8.0
@export var deacceleration: float = 20.0
@export var jump_impulse: float = 4.5
@export var sensitivity: float = 0.005

@export var bob_freq: float = 2.0
@export var bob_amp: float = 0.08
var t_bob = 0.0

@onready var head: Node3D = %Head
@onready var camera: Camera3D = %Camera3D

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(40))
		
	if event.is_action_pressed('exit'):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_impulse
	
	var speed: float = walk_speed
	if Input.is_action_pressed('sprint'):
		speed = run_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = move_toward(velocity.x, 0, deacceleration * delta)
			velocity.z = move_toward(velocity.z, 0, deacceleration * delta)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.y = lerp(velocity.y, direction.y * speed, delta * 3.0)

	# Head bob
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

	move_and_slide()

func _headbob(time: float) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * bob_freq) * bob_amp
	pos.x = cos(time * bob_freq / 2.0) * bob_amp
	return pos