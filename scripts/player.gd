extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_speed: float = 7.5
@export var gravity_strength: float = 18.0
@export var mouse_sensitivity: float = 0.002

@onready var camera: Camera3D = $Camera3D

var gravity_direction: Vector3 = Vector3.DOWN
var pitch: float = 0.0

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	up_direction = Vector3.UP

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_G:
			flip_gravity()
	if event is InputEventMouseButton and event.pressed:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * mouse_sensitivity)
		pitch = clamp(pitch - event.relative.y * mouse_sensitivity, deg_to_rad(-85.0), deg_to_rad(85.0))
		camera.rotation.x = pitch

func _physics_process(delta: float) -> void:
	up_direction = -gravity_direction
	if not is_on_floor():
		velocity += gravity_direction * gravity_strength * delta

	var input_2d := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var forward := -global_basis.z
	var right := global_basis.x
	var wish_direction := right * input_2d.x + forward * -input_2d.y
	wish_direction = wish_direction.slide(gravity_direction).normalized()

	if wish_direction.length_squared() > 0.001:
		velocity.x = wish_direction.x * move_speed
		velocity.z = wish_direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, move_speed)
		velocity.z = move_toward(velocity.z, 0.0, move_speed)

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity = velocity.slide(gravity_direction) - gravity_direction * jump_speed

	move_and_slide()

func flip_gravity() -> void:
	gravity_direction = -gravity_direction
	var tween := create_tween()
	tween.tween_property(self, "rotation:z", rotation.z + PI, 0.22)
	velocity = velocity.slide(gravity_direction)
