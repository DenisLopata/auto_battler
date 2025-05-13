extends Node2D

@onready var fight_manager = $FightManager
@onready var arena_controller = $ArenaController
@onready var hud_left = $UI/FighterHUD
@onready var hud_right = $UI/FighterHUDRight
@onready var start_button = $UI/StartButton
@onready var camera_rig: Node2D = $CameraRig

func _ready():
	fight_manager.setup(arena_controller, hud_left, hud_right, start_button, camera_rig)
	
	arena_controller.fighters_ready.connect(_on_arena_controller_fighters_ready)
	
func _on_arena_controller_fighters_ready(fighter_left: Fighter, fighter_right: Fighter) -> void:
	camera_rig._on_fighters_ready(fighter_left, fighter_right)
