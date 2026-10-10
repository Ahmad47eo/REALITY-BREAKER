extends Node3D

# Procedural streamed world: the game only keeps a 3x3 area of chunks loaded.
# Moving forever creates new regions from a deterministic coordinate-based seed.
const CHUNK_SIZE: float = 120.0
const LOAD_RADIUS: int = 1

@onready var player: CharacterBody3D = $Player

var loaded_chunks: Dictionary = {}
var current_chunk: Vector2i = Vector2i(999999, 999999)

func _ready() -> void:
	_refresh_chunks(true)

func _process(_delta: float) -> void:
	var player_chunk := _chunk_for_position(player.global_position)
	if player_chunk != current_chunk:
		_refresh_chunks(false)

func _chunk_for_position(position: Vector3) -> Vector2i:
	return Vector2i(floori(position.x / CHUNK_SIZE), floori(position.z / CHUNK_SIZE))

func _refresh_chunks(force: bool) -> void:
	current_chunk = _chunk_for_position(player.global_position)
	var wanted: Dictionary = {}
	for z in range(current_chunk.y - LOAD_RADIUS, current_chunk.y + LOAD_RADIUS + 1):
		for x in range(current_chunk.x - LOAD_RADIUS, current_chunk.x + LOAD_RADIUS + 1):
			var coord := Vector2i(x, z)
			wanted[coord] = true
			if not loaded_chunks.has(coord):
				loaded_chunks[coord] = _build_chunk(coord)
	for coord in loaded_chunks.keys():
		if not wanted.has(coord):
			var old_chunk: Node3D = loaded_chunks[coord]
			old_chunk.queue_free()
			loaded_chunks.erase(coord)

func _build_chunk(coord: Vector2i) -> Node3D:
	var chunk := Node3D.new()
	chunk.name = "Chunk_%d_%d" % [coord.x, coord.y]
	chunk.position = Vector3(coord.x * CHUNK_SIZE, 0.0, coord.y * CHUNK_SIZE)
	add_child(chunk)

	var rng := RandomNumberGenerator.new()
	rng.seed = absi(coord.x * 73856093 + coord.y * 19349663 + 8349271)

	var biome := posmod(coord.x, 3)
	match biome:
		0:
			_build_city(chunk, rng)
		1:
			_build_wildlands(chunk, rng)
		_:
			_build_reality_zone(chunk, rng)
	return chunk

func _build_city(chunk: Node3D, rng: RandomNumberGenerator) -> void:
	var road_material := _material(Color(0.075, 0.095, 0.13), 0.95)
	_add_box(chunk, "CityGround", Vector3(0, -1, 0), Vector3(CHUNK_SIZE, 2, CHUNK_SIZE), Color(0.17, 0.2, 0.23))
	_add_visual_box(chunk, "NorthSouthRoad", Vector3(0, 0.025, 0), Vector3(12, 0.05, CHUNK_SIZE), road_material)
	_add_visual_box(chunk, "EastWestRoad", Vector3(0, 0.03, 0), Vector3(CHUNK_SIZE, 0.05, 12), road_material)

	var building_colors := [
		Color(0.13, 0.19, 0.28), Color(0.18, 0.23, 0.32),
		Color(0.23, 0.25, 0.34), Color(0.11, 0.16, 0.23)
	]
	for i in range(15):
		var x := rng.randf_range(-53.0, 53.0)
		var z := rng.randf_range(-53.0, 53.0)
		if absf(x) < 10.0 or absf(z) < 10.0:
			continue
		var width := rng.randf_range(7.0, 13.0)
		var depth := rng.randf_range(7.0, 13.0)
		var height := rng.randf_range(8.0, 27.0)
		var tint: Color = building_colors[rng.randi_range(0, building_colors.size() - 1)]
		_add_box(chunk, "Building_%02d" % i, Vector3(x, height * 0.5, z), Vector3(width, height, depth), tint)
		# Bright roof markers make distant city blocks easier to read.
		_add_visual_box(chunk, "RoofLight_%02d" % i, Vector3(x, height + 0.15, z), Vector3(width * 0.55, 0.3, 0.35), _material(Color(0.1, 0.75, 1.0), 0.4, true))

func _build_wildlands(chunk: Node3D, rng: RandomNumberGenerator) -> void:
	_add_box(chunk, "WildlandGround", Vector3(0, -1, 0), Vector3(CHUNK_SIZE, 2, CHUNK_SIZE), Color(0.16, 0.31, 0.19))
	for i in range(24):
		var x := rng.randf_range(-55.0, 55.0)
		var z := rng.randf_range(-55.0, 55.0)
		var scale := rng.randf_range(0.75, 1.45)
		var trunk_height := 4.5 * scale
		var tree := StaticBody3D.new()
		tree.name = "Tree_%02d" % i
		tree.position = Vector3(x, trunk_height * 0.5, z)
		chunk.add_child(tree)
		var trunk_mesh := CylinderMesh.new()
		trunk_mesh.top_radius = 0.35 * scale
		trunk_mesh.bottom_radius = 0.55 * scale
		trunk_mesh.height = trunk_height
		var trunk := MeshInstance3D.new()
		trunk.mesh = trunk_mesh
		trunk.material_override = _material(Color(0.28, 0.16, 0.09))
		tree.add_child(trunk)
		var trunk_shape := CollisionShape3D.new()
		var cylinder := CylinderShape3D.new()
		cylinder.radius = 0.48 * scale
		cylinder.height = trunk_height
		trunk_shape.shape = cylinder
		tree.add_child(trunk_shape)
		var crown_mesh := SphereMesh.new()
		crown_mesh.radius = 2.0 * scale
		crown_mesh.height = 4.0 * scale
		var crown := MeshInstance3D.new()
		crown.mesh = crown_mesh
		crown.position.y = trunk_height * 0.5 + 1.2 * scale
		crown.material_override = _material(Color(0.08, rng.randf_range(0.28, 0.42), 0.14))
		tree.add_child(crown)
	for i in range(12):
		var rock_size := rng.randf_range(1.5, 4.0)
		var rock := _add_box(chunk, "Rock_%02d" % i, Vector3(rng.randf_range(-55, 55), rock_size * 0.35, rng.randf_range(-55, 55)), Vector3(rock_size * 1.5, rock_size * 0.7, rock_size), Color(0.32, 0.36, 0.31))
		rock.rotation.y = rng.randf_range(0.0, TAU)

func _build_reality_zone(chunk: Node3D, rng: RandomNumberGenerator) -> void:
	_add_box(chunk, "RealityGround", Vector3(0, -1, 0), Vector3(CHUNK_SIZE, 2, CHUNK_SIZE), Color(0.09, 0.12, 0.23))
	var glow := _material(Color(0.05, 0.65, 1.0), 0.35, true)
	var crystal_material := _material(Color(0.18, 0.3, 0.52), 0.3, false)
	for i in range(12):
		var x := rng.randf_range(-52.0, 52.0)
		var z := rng.randf_range(-52.0, 52.0)
		var height := rng.randf_range(7.0, 19.0)
		var pylon := StaticBody3D.new()
		pylon.name = "RealityPylon_%02d" % i
		pylon.position = Vector3(x, height * 0.5, z)
		chunk.add_child(pylon)
		var mesh := CylinderMesh.new()
		mesh.top_radius = 0.2
		mesh.bottom_radius = rng.randf_range(0.8, 1.5)
		mesh.height = height
		var visual := MeshInstance3D.new()
		visual.mesh = mesh
		visual.material_override = crystal_material
		pylon.add_child(visual)
		var shape_node := CollisionShape3D.new()
		var shape := CylinderShape3D.new()
		shape.radius = 1.1
		shape.height = height
		shape_node.shape = shape
		pylon.add_child(shape_node)
		_add_visual_box(chunk, "PylonLight_%02d" % i, Vector3(x, height + 0.15, z), Vector3(2.0, 0.35, 2.0), glow)

	# A few floating platforms reward experimenting with gravity flipping.
	for i in range(3):
		var x := rng.randf_range(-42.0, 42.0)
		var z := rng.randf_range(-42.0, 42.0)
		_add_box(chunk, "FloatingPlatform_%02d" % i, Vector3(x, rng.randf_range(9.0, 16.0), z), Vector3(9.0, 1.0, 9.0), Color(0.12, 0.22, 0.34))

func _add_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, color: Color) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = node_name
	body.position = position
	parent.add_child(body)
	var mesh := BoxMesh.new()
	mesh.size = size
	var visual := MeshInstance3D.new()
	visual.mesh = mesh
	visual.material_override = _material(color)
	body.add_child(visual)
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return body

func _add_visual_box(parent: Node3D, node_name: String, position: Vector3, size: Vector3, material: Material) -> void:
	var visual := MeshInstance3D.new()
	visual.name = node_name
	visual.position = position
	var mesh := BoxMesh.new()
	mesh.size = size
	visual.mesh = mesh
	visual.material_override = material
	parent.add_child(visual)

func _material(color: Color, roughness: float = 0.8, emissive: bool = false) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = roughness
	if emissive:
		material.emission_enabled = true
		material.emission = color
		material.emission_energy_multiplier = 1.4
	return material
