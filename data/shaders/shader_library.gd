# res://data/shaders/shader_library.gd
class_name ShaderLibrary
extends Node

@export var shaders: Array[ShaderDefinition]


func _ready() -> void:
	# Pink Flashing Shader
	var pink := ShaderDefinition.new()
	pink.shader_path = "res://assets/shaders/pink_flashing.gdshader"
	pink.default_parameters = {
		"pulse_strength": 1.0,
		"tint_color": Color(1.0, 0.0, 0.5)
	}
	shaders.append(pink)

	# Neon Pulse Shader
	var neon := ShaderDefinition.new()
	neon.shader_path = "res://assets/shaders/neon_pulse.gdshader"
	neon.default_parameters = {
		"intensity": 0.8,
		"time_speed": 1.2,
		"neon_color": Color(0.0, 1.0, 1.0)
	}
	shaders.append(neon)

	# Retro Black & White Shader
	var retro := ShaderDefinition.new()
	retro.shader_path = "res://assets/shaders/retro_black_white.gdshader"
	retro.default_parameters = {
		"crt_intensity": 0.1
	}
	shaders.append(retro)

	# Fire Brawler Shader
	var heat := ShaderDefinition.new()
	heat.shader_path = "res://assets/shaders/heat_distortion.gdshader"
	heat.default_parameters = {
		"heat_intensity": 0.2
	}
	shaders.append(heat)

	# Electric Mage Shader
	var pulse := ShaderDefinition.new()
	pulse.shader_path = "res://assets/shaders/pulse.gdshader"
	pulse.default_parameters = {
		"zap_intensity": 0.2
	}
	shaders.append(pulse)

	# Shadow Assassin Shader
	var shadows := ShaderDefinition.new()
	shadows.shader_path = "res://assets/shaders/shadows.gdshader"
	shadows.default_parameters = {
		"shadow_strength": 0.2
	}
	shaders.append(shadows)
	
	# Water Elemental Shader
	var water := ShaderDefinition.new()
	water.shader_path = "res://assets/shaders/water_shade.gdshader"
	water.default_parameters = {
		"water_intensity": 0.3
	}
	shaders.append(water)


func get_random_shader() -> ShaderDefinition:
	if shaders.is_empty(): return null
	return shaders[randi() % shaders.size()]
