extends Node2D

@onready var fight_manager = $FightManager
@onready var arena_controller = $ArenaController
@onready var hud_left = $UI/FighterHUD
@onready var hud_right = $UI/FighterHUDRight
@onready var start_button = $UI/StartButton
@onready var camera_rig: Node2D = $CameraRig
@onready var background_image: TextureRect = $BackgroundImage

var specials_active := 0

func _ready():
	fight_manager.setup(arena_controller, hud_left, hud_right, start_button, camera_rig)
	
	arena_controller.fighters_ready.connect(_on_arena_controller_fighters_ready)
	deactivate_special_background_effect()
	SignalBus.special_mode_started.connect(_on_special_mode_started)
	SignalBus.special_mode_ended.connect(_on_special_mode_ended)
	
func _on_arena_controller_fighters_ready(fighter_left: Fighter, fighter_right: Fighter) -> void:
	camera_rig._on_fighters_ready(fighter_left, fighter_right)


func _on_special_mode_started(fighter):
	specials_active += 1
	activate_special_background_effect()

func _on_special_mode_ended(fighter):
	specials_active -= 1
	if specials_active <= 0:
		deactivate_special_background_effect()

func activate_special_background_effect():
	var mat := background_image.material as ShaderMaterial
	#mat.set_shader_parameter("pulse_strength", 1.0)
	mat.set_shader_parameter("pulse_strength", 0.3)
	
func deactivate_special_background_effect():
	var mat := background_image.material as ShaderMaterial
	mat.set_shader_parameter("pulse_strength", 0.0)
