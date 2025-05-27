# res://scenes/arena/ArenaMain.tscn
class_name ArenaMain
extends Node2D

const ShaderLibrary = preload("res://data/shaders/shader_library.gd")

var specials_active := 0

@onready var fight_manager: FightManager = $FightManager
@onready var arena_controller: ArenaController = $ArenaController
@onready var hud_left = $UI/FighterHUD
@onready var hud_right = $UI/FighterHUDRight
@onready var start_button = $UI/StartButton
@onready var camera_rig: Node2D = $CameraRig
@onready var background_image: TextureRect = $BackgroundImage
@onready var background_overlay: TextureRect = $BackgroundOverlay
@onready var shader_manager: ShaderManager = $ShaderManager
@onready var bet_manager: BetManager = $BetManager
@onready var betting_panel: BettingPanel = $UI/BettingPanel

func _ready() -> void:
	setup_fight_manager()
	setup_betting()
	setup_background_shader()
	connect_signals()
	
func setup_fight_manager() -> void:
	fight_manager.setup(arena_controller, \
	hud_left, hud_right, start_button, \
	camera_rig, background_image, background_overlay)
	arena_controller.fighters_ready.connect(_on_arena_controller_fighters_ready)
	arena_controller.fight_ended.connect(_on_arena_fight_ended)


func setup_betting() -> void:
	bet_manager.bet_confirmed.connect(_on_bet_confirmed)
	bet_manager.score_changed.connect(_on_score_changed)
	betting_panel.visible = false
	betting_panel.bet_made.connect(_on_bet_locked)


func setup_background_shader() -> void:
	var sl := ShaderLibrary.new()
	sl._ready()
	var shader_def := sl.get_random_shader()
	var shader := load(shader_def.shader_path)
	var mat := ShaderMaterial.new()
	mat.shader = shader

	for key in shader_def.default_parameters.keys():
		mat.set_shader_parameter(key, shader_def.default_parameters[key])

	background_image.material = mat
	shader_manager.set_background_material(mat as ShaderMaterial, shader_def)
	#shader_manager.activate_fighter_shader("")
	#shader_manager.start_special_background()


func connect_signals():
	SignalBus.special_mode_started.connect(_on_special_mode_started)
	SignalBus.special_mode_ended.connect(_on_special_mode_ended)
	
	fight_manager.start_pressed.connect(_on_fight_manager_start_pressed)

	
#region Signals

func _on_fight_manager_start_pressed() -> void:
	setup_background_shader()

func _on_arena_controller_fighters_ready(fighter_left: Fighter, fighter_right: Fighter) -> void:
	camera_rig._on_fighters_ready(fighter_left, fighter_right)
	betting_panel.set_fighters(fighter_left, fighter_right)
	betting_panel.update_score(str(bet_manager.total_score))
	betting_panel.visible = true
	
func _on_arena_fight_ended(winner: Fighter, loser: Fighter) -> void:
	bet_manager.update_score(winner)
	
func _on_special_mode_started(fighter):
	specials_active += 1
	shader_manager.start_special_background()

func _on_special_mode_ended(fighter):
	specials_active -= 1
	if specials_active <= 0:
		shader_manager.end_special_background()

func _on_bet_confirmed(fighter: Fighter):
	print("Bet confirmed on: ", fighter.fighter_name)
	# Start the fight now
	fight_manager.start_fight()

func _on_score_changed(score: int):
	print("New Score: ", score)

func _on_bet_locked(fighter: Fighter):
	betting_panel.visible = false
	bet_manager.place_bet(fighter)
	fight_manager.start_fight()

#endregion
