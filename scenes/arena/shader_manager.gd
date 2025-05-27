class_name ShaderManager
extends Node

var background_material: ShaderMaterial
var current_shader_definition: ShaderDefinition
var fighter_shaders := {}

func set_background_material(mat: ShaderMaterial, shader_def: ShaderDefinition):
	background_material = mat
	current_shader_definition = shader_def
	
	# Automatically zero out *_intensity and *_strength parameters
	for key in shader_def.default_parameters.keys():
		if key.ends_with("intensity") or key.ends_with("strength"):
			mat.set_shader_parameter(key, 0.0)

func start_special_background():
	if background_material and current_shader_definition:
		for key in current_shader_definition.default_parameters.keys():
			if key.ends_with("intensity") or key.ends_with("strength"):
				background_material.set_shader_parameter(key, 0.5)

func end_special_background():
	if background_material and current_shader_definition:
		for key in current_shader_definition.default_parameters.keys():
			if key.ends_with("intensity") or key.ends_with("strength"):
				background_material.set_shader_parameter(key, 0.0)


#func start_special_background():
	#if background_material:
		#background_material.set_shader_parameter("pulse_strength", 1.0)
#
#func end_special_background():
	#if background_material:
		#background_material.set_shader_parameter("pulse_strength", 0.0)

func register_fighter_shader(fighter_id: String, mat: ShaderMaterial):
	fighter_shaders[fighter_id] = mat

func activate_fighter_shader(fighter_id: String):
	var mat = fighter_shaders.get(fighter_id)
	if mat:
		# Customize for that shader
		var shader_strength = 0.3
		mat.set_shader_parameter("effect_strength", shader_strength)

func deactivate_fighter_shader(fighter_id: String):
	var mat = fighter_shaders.get(fighter_id)
	if mat:
		mat.set_shader_parameter("effect_strength", 0.0)
