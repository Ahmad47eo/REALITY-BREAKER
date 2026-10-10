extends CharacterBody3D

@export var move_speed: float = 6.0
@export var jump_speed: float = 7.5
@export var gravity_strength: float = 18.0
@export var mouse_sensitivity: float = 0.002
@export var touch_look_sensitivity: float = 0.004

@onready var camera: Camera3D = $Camera3D
@onready var status_label: Label = $"../HUD/Info"

var gravity_direction: Vector3 = Vector3.DOWN
var pitch: float = 0.0
var mobile_hud: CanvasLayer
var mobile_hint: Label
var look_touch_index: int = -1
var move_touch_index: int = -1
var move_touch_origin: Vector2 = Vector2.ZERO
var move_touch_vector: Vector2 = Vector2.ZERO
var mobile_controls_enabled: bool = false
var touch_buttons: Dictionary = {}

func _ready() -> void:
	up_direction = Vector3.UP
	mobile_controls_enabled = OS.get_name() == "Web" or DisplayServer.is_touchscreen_available() or OS.has_feature("web")
	if not mobile_controls_enabled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_update_hud()
	if mobile_controls_enabled:
		_create_mobile_controls()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		if event.keycode == KEY_ESCAPE:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		elif event.keycode == KEY_G:
			flip_gravity()
	if event is InputEventMouseButton and event.pressed and not mobile_controls_enabled:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_apply_look(event.relative, mouse_sensitivity)

func _input(event: InputEvent) -> void:
	if not mobile_controls_enabled:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	if event is InputEventScreenTouch:
		if event.pressed:
			if event.position.x < viewport_size.x * 0.48 and event.position.y > viewport_size.y * 0.28 and move_touch_index == -1:
				move_touch_index = event.index
				move_touch_origin = event.position
				move_touch_vector = Vector2.ZERO
				_update_touch_movement()
			elif event.position.x >= viewport_size.x * 0.48 and event.position.y < viewport_size.y * 0.68 and look_touch_index == -1:
				look_touch_index = event.index
		else:
			if event.index == move_touch_index:
				move_touch_index = -1
				move_touch_vector = Vector2.ZERO
				_update_touch_movement()
			if event.index == look_touch_index:
				look_touch_index = -1
	elif event is InputEventScreenDrag:
		if event.index == move_touch_index:
			move_touch_vector = (event.position - move_touch_origin) / 58.0
			if move_touch_vector.length() > 1.0:
				move_touch_vector = move_touch_vector.normalized()
			_update_touch_movement()
		elif event.index == look_touch_index:
			_apply_look(event.relative, touch_look_sensitivity)

func _apply_look(relative: Vector2, sensitivity: float) -> void:
	global_basis = Basis(up_direction, -relative.x * sensitivity) * global_basis
	pitch = clamp(pitch - relative.y * sensitivity, deg_to_rad(-85.0), deg_to_rad(85.0))
	camera.rotation.x = pitch

func _update_touch_movement() -> void:
	_set_touch_action("move_left", move_touch_vector.x < -0.22)
	_set_touch_action("move_right", move_touch_vector.x > 0.22)
	_set_touch_action("move_forward", move_touch_vector.y < -0.22)
	_set_touch_action("move_back", move_touch_vector.y > 0.22)

func _set_touch_action(action: String, active: bool) -> void:
	if active:
		Input.action_press(action)
	else:
		Input.action_release(action)

func _create_mobile_controls() -> void:
	mobile_hud = CanvasLayer.new()
	mobile_hud.name = "MobileControls"
	mobile_hud.layer = 10 # Keep touch controls above the regular HUD.
	add_child(mobile_hud)

	var root := Control.new()
	root.name = "TouchOverlay"
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.z_index = 100
	mobile_hud.add_child(root)

	mobile_hint = Label.new()
	mobile_hint.text = "MOBILE CONTROLS ACTIVE  •  DRAG TO MOVE / LOOK"
	mobile_hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	mobile_hint.set_anchors_preset(Control.PRESET_CENTER_BOTTOM)
	mobile_hint.anchor_left = 0.25
	mobile_hint.anchor_right = 0.75
	mobile_hint.anchor_top = 1.0
	mobile_hint.anchor_bottom = 1.0
	mobile_hint.offset_top = -36
	mobile_hint.offset_bottom = -12
	mobile_hint.add_theme_font_size_override("font_size", 13)
	mobile_hint.add_theme_color_override("font_color", Color(0.72, 0.9, 1.0, 0.85))
	mobile_hint.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(mobile_hint)

	_add_mobile_button(root, "JUMP", Vector2(1.0, 1.0), Vector2(-174, -142), Vector2(76, 64), "jump")
	_add_mobile_button(root, "FLIP\nGRAVITY", Vector2(1.0, 1.0), Vector2(-94, -218), Vector2(86, 72), "flip_gravity_touch")
	_add_mobile_button(root, "↑", Vector2(0.0, 1.0), Vector2(100, -174), Vector2(58, 58), "move_forward")
	_add_mobile_button(root, "↓", Vector2(0.0, 1.0), Vector2(100, -60), Vector2(58, 58), "move_back")
	_add_mobile_button(root, "←", Vector2(0.0, 1.0), Vector2(42, -117), Vector2(58, 58), "move_left")
	_add_mobile_button(root, "→", Vector2(0.0, 1.0), Vector2(158, -117), Vector2(58, 58), "move_right")

func _add_mobile_button(root: Control, caption: String, anchor: Vector2, position: Vector2, size: Vector2, action: String) -> void:
	var button := Button.new()
	button.text = caption
	button.anchor_left = anchor.x
	button.anchor_right = anchor.x
	button.anchor_top = anchor.y
	button.anchor_bottom = anchor.y
	button.offset_left = position.x
	button.offset_top = position.y
	button.offset_right = position.x + size.x
	button.offset_bottom = position.y + size.y
	button.focus_mode = Control.FOCUS_NONE
	button.add_theme_font_size_override("font_size", 15)
	button.add_theme_color_override("font_color", Color(0.88, 0.96, 1.0))
	button.add_theme_color_override("font_pressed_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _mobile_button_style(Color(0.08, 0.16, 0.27, 0.78)))
	button.add_theme_stylebox_override("pressed", _mobile_button_style(Color(0.12, 0.48, 0.66, 0.95)))
	button.add_theme_stylebox_override("hover", _mobile_button_style(Color(0.1, 0.27, 0.4, 0.9)))
	button.mouse_filter = Control.MOUSE_FILTER_STOP
	root.add_child(button)
	if action == "flip_gravity_touch":
		button.pressed.connect(flip_gravity)
	else:
		button.button_down.connect(func(): Input.action_press(action))
		button.button_up.connect(func(): Input.action_release(action))
	touch_buttons[action] = button

func _mobile_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.border_color = Color(0.35, 0.75, 0.95, 0.85)
	style.set_border_width_all(1)
	style.set_corner_radius_all(14)
	style.content_margin_left = 5
	style.content_margin_right = 5
	style.content_margin_top = 4
	style.content_margin_bottom = 4
	return style

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
	var controls := "Touch: arrows move • drag right to look • Jump • Flip Gravity" if mobile_controls_enabled else "WASD Move   •   Mouse Look   •   SPACE Jump   •   G Flip Gravity   •   ESC Release Mouse"
	status_label.text = "REALITY BREAKER  |  GRAVITY: %s\n%s" % [surface, controls]
