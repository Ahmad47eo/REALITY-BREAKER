extends Node

# Conservative hardware detection: never assumes that shared GPU memory is dedicated VRAM.
# Profiles are applied at runtime and can be overridden later by a Settings menu.
@export var allow_automatic_quality: bool = true

var profile_name: String = "Balanced"
var chunk_radius: int = 1
var density_multiplier: float = 0.8
var target_fps: int = 60
var detected_ram_gb: float = 0.0
var detected_cpu_threads: int = 1
var detected_gpu: String = "Unknown GPU"
var detected_os: String = "Unknown OS"

@onready var quality_label: Label = get_node_or_null("../HUD/QualityInfo") as Label

func _ready() -> void:
	_detect_and_apply()

func _detect_and_apply() -> void:
	detected_os = OS.get_name()
	detected_cpu_threads = maxi(1, OS.get_processor_count())
	detected_gpu = RenderingServer.get_video_adapter_name()
	detected_ram_gb = _get_system_ram_gb()

	# Web/mobile builds have tighter memory budgets. Native desktop gets a profile
	# based on CPU threads and system RAM; GPU vendor/name is recorded for display,
	# but not treated as a reliable VRAM measurement.
	if detected_os == "Web":
		profile_name = "Web Balanced"
		chunk_radius = 1
		density_multiplier = 0.65
		target_fps = 45
	elif detected_ram_gb > 0.0 and detected_ram_gb <= 4.5 or detected_cpu_threads <= 4:
		profile_name = "Low-End"
		chunk_radius = 1
		density_multiplier = 0.45
		target_fps = 30
	elif detected_ram_gb >= 16.0 and detected_cpu_threads >= 8:
		profile_name = "High"
		chunk_radius = 2
		density_multiplier = 1.0
		target_fps = 60
	else:
		profile_name = "Balanced"
		chunk_radius = 1
		density_multiplier = 0.72
		target_fps = 60

	if not allow_automatic_quality:
		return

	Engine.max_fps = target_fps
	var world := get_parent()
	if world != null and world.has_method("apply_performance_profile"):
		world.call("apply_performance_profile", profile_name, chunk_radius, density_multiplier)

	if quality_label != null:
		quality_label.text = "AUTO: %s  |  %s threads  |  %s RAM  |  %s" % [
			profile_name,
			str(detected_cpu_threads),
			("unknown" if detected_ram_gb <= 0.0 else "%.0f GB" % detected_ram_gb),
			detected_gpu
		]

func _get_system_ram_gb() -> float:
	# Godot 4.3 exposes system memory information on supported native platforms.
	# Some browser targets do not expose it; zero means unknown, not zero RAM.
	if OS.get_name() == "Web":
		return 0.0
	var memory_info: Dictionary = OS.get_memory_info()
	var physical_bytes: int = int(memory_info.get("physical", 0))
	if physical_bytes <= 0:
		physical_bytes = int(memory_info.get("total", 0))
	return float(physical_bytes) / 1073741824.0
