extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_speed: float = 7.5
@export var gravity_strength: float = 18.0
@export var mouse_sensitivity: float = 0.002

@onready var camera: Camera3D = $Camera3D
@onready var status_label: Label = $"../HUD/Info"

var gravity_direction: Vector3 = Vector3.DOWN
var pitch: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	up_direction = Vector3.UP
	_update_hud()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_G:
			flip_gravity()
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Yaw around the player's current up axis so controls still work on the ceiling.
		global_basis = Basis(up_direction, -event.relative.x * mouse_sensitivity) * global_basis
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-85.0), deg_to_rad(85.0))
		camera.rotation.x = pitch

func _physics_process(delta: float) -> void:
	up_direction = -gravity_direction

	if not is_on_floor():
		velocity += gravity_direction * gravity_strength * delta
	elif velocity.dot(gravity_direction) > 0.0:
		velocity = velocity.slide(gravity_direction)

	var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := (-global_basis.z).slide(up_direction).normalized()
	var right := global_basis.x.slide(up_direction).normalized()
	var wish_direction := (right * input_2d.x - forward * input_2d.y).normalized()
	var vertical_speed := velocity.dot(gravity_direction)

	if wish_direction.length_squared() > 0.001:
		velocity = wish_direction * move_speed + gravity_direction * vertical_speed
	else:
		var horizontal_velocity := velocity.slide(gravity_direction)
		horizontal_velocity = horizontal_velocity.move_toward(Vector3.ZERO, move_speed * 5.0 * delta)
		velocity = horizontal_velocity + gravity_direction * vertical_speed

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity = velocity.slide(gravity_direction) - gravity_direction * jump_speed

	move_and_slide()

func flip_gravity() -> void:
	# Rotate around the player's forward axis, keeping the view direction stable.
	var forward_axis := -global_basis.z.normalized()
	global_basis = Basis(forward_axis, PI) * global_basis
	gravity_direction = -gravity_direction
	up_direction = -gravity_direction
	velocity = velocity.slide(gravity_direction)
	_update_hud()

func _update_hud() -> void:
	if not is_node_ready() or status_label == null:
		return
	var surface := "FLOOR" if gravity_direction == Vector3.DOWN else "CEILING"
	status_label.text = "REALITY BREAKER  |  GRAVITY: %s\nWASD Move   •   Mouse Look   •   SPACE Jump   •   G Flip Gravity   •   ESC Release Mouse" % surface
