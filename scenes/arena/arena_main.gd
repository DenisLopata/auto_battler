extends Node2D

@onready var fight_manager = $FightManager
@onready var arena_controller = $ArenaController
@onready var hud_left = $UI/FighterHUD
@onready var hud_right = $UI/FighterHUDRight
@onready var start_button = $UI/StartButton

func _ready():
	fight_manager.setup(arena_controller, hud_left, hud_right, start_button)
