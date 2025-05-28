class_name FightManager
extends Node

signal start_pressed
signal fight_started
signal fight_ended

@export var fighter_scene: PackedScene

var arena_controller: ArenaController
var hud_left: FighterHUD
var hud_right: FighterHUD
var start_button: Button
var camera_rig: Node2D
var background_image: TextureRect
var background_overlay: TextureRect

var fighter_left: Fighter = null
var fighter_right: Fighter = null

var include_mythological_names := true

func setup(arena: Node, left_hud: FighterHUD, right_hud: FighterHUD, \
button: Button, camera_rig: Node2D, \
_background_image: TextureRect, _background_overlay: TextureRect):
	arena_controller = arena
	hud_left = left_hud
	hud_right = right_hud
	start_button = button
	start_button.pressed.connect(_on_start_pressed)
	start_button.disabled = false
	
	arena_controller.fight_ended.connect(_on_fight_ended)
	arena_controller.camera_rig = camera_rig
	arena_controller.background_image = _background_image
	arena_controller.background_overlay = _background_overlay
	background_image = _background_image
	background_overlay = _background_overlay
	
func _on_start_pressed():
	start_button.disabled = true
	prepare_fighters()
	prepare_background()
	start_pressed.emit()
	#start_fight()

func prepare_background():
	var backgrounds = arena_controller.get_available_backgrounds()
	var random_bg = backgrounds[randi() % backgrounds.size()]
	arena_controller.set_background(random_bg)
	
func prepare_fighters():
	clear_fighters()

	# Create and track fighters
	fighter_left = fighter_scene.instantiate()
	fighter_right = fighter_scene.instantiate()

	fighter_left.fighter_name = get_random_name()
	fighter_right.fighter_name = get_random_name()

	var chosen = choose_archetypes()
	
	if chosen[0] == "random":
		randomize_stats(fighter_left)
	else:
		apply_archetype_stats(fighter_left, chosen[0])

	if chosen[1] == "random":
		randomize_stats(fighter_right)
	else:
		apply_archetype_stats(fighter_right, chosen[1])
	
	##randomize_stats(fighter_left)
	##randomize_stats(fighter_right)
	#
	##apply_archetype_stats(fighter_left, "Strength")
	##apply_archetype_stats(fighter_left, "Endurance")
	##apply_archetype_stats(fighter_left, "Technique")
	#apply_archetype_stats(fighter_left, "Agility")
	#
	##apply_archetype_stats(fighter_right, "Strength")
	##apply_archetype_stats(fighter_right, "Endurance")
	##apply_archetype_stats(fighter_right, "Technique")
	#apply_archetype_stats(fighter_right, "Agility")
#
	##debug stats
	#fighter_left.base_stats.endurance = 1
	##fighter_left.base_stats.agility = 1
	#fighter_left.base_stats.technique = 50
	
	add_child(fighter_left)
	add_child(fighter_right)
	fighter_left.name = "FighterLeft"
	fighter_right.name = "FighterRight"

	fighter_left.position = Vector2(200, 150)
	fighter_right.position = Vector2(400, 150)
	fighter_right.flip_sprite(true)


	hud_left.fighters = [fighter_left]
	hud_right.fighters = [fighter_right]
	hud_left._initialize_ui()
	hud_right._initialize_ui()

	fighter_left.context.target_fighter = fighter_right
	fighter_right.context.target_fighter = fighter_left
	
	arena_controller.set_fighters(fighter_left, fighter_right)

func start_fight():
	arena_controller.start_fight()
	fight_started.emit()


func clear_fighters():
	if fighter_left and is_instance_valid(fighter_left):
		fighter_left.queue_free()
	if fighter_right and is_instance_valid(fighter_right):
		fighter_right.queue_free()
	fighter_left = null
	fighter_right = null

func _on_fight_ended(winner: Fighter, loser: Fighter):
	start_button.disabled = false
	fight_ended.emit(winner, loser)

#region Random fighters

var base_name_pool = [
	"Crusher", "Steel Fist", "Iron Jaw", "Quickstep", "Shadow", "Bruiser", "Rage", "Ghost", "Blitz", "The Wall",
	"Viper", "Knockout", "Slab", "Scythe", "Fury", "Echo", "Spike", "Venom", "Torque", "Frost",
	"Brick", "Shiv", "Pyro", "Razor", "Bulldog", "Ox", "Dagger", "Smash", "Phantom", "Talon",
	"Grit", "Steeltoe", "Howl", "Snap", "Jinx", "Mauler", "Clutch", "Bruin", "Volt", "Fang"
]

var mythological_name_pool = [
	"Ares", "Athena", "Thor", "Loki", "Hera", "Hades", "Freya", 
	"Fenrir", "Anubis", "Osiris", "Ra", "Set", "Kali", "Odin", 
	"Persephone", "Zeus", "Apollo", "Artemis", "Hermes", "Achilles"
]

func choose_archetypes() -> Array[String]:
	var archetypes = ["Strength", "Endurance", "Technique", "Agility"]

	if randf() < 0.8:
		# 80% chance: fully random stats for both
		return ["random", "random"]

	# 80% chance: use predefined archetypes
	var a1 = archetypes[randi() % archetypes.size()]
	var mirror_chance = randf()
	var a2 = a1 if mirror_chance < 0.5 else (archetypes.filter(func(a): return a != a1))[randi() % 3]

	return [a1, a2]

func get_random_name() -> String:
	var combined_pool = base_name_pool.duplicate()
	if include_mythological_names:
		combined_pool += mythological_name_pool
	return combined_pool[randi() % combined_pool.size()]
	
func randomize_stats(fighter: Fighter):
	var stats := FighterStats.new()
	stats.strength = randi_range(5, 15)
	stats.endurance = randi_range(5, 15)
	stats.technique = randi_range(5, 15)
	stats.agility = randi_range(5, 15)
	fighter.base_stats = stats

func apply_archetype_stats(fighter: Fighter, archetype: String) -> void:
	var stats := FighterStats.new()

	match archetype:
		"Strength":
			stats.strength = 20
			stats.endurance = 10
			stats.technique = 5
			stats.agility = 5
		"Endurance":
			stats.strength = 8
			stats.endurance = 20
			stats.technique = 6
			stats.agility = 6
		"Technique":
			stats.strength = 6
			stats.endurance = 8
			stats.technique = 20
			stats.agility = 6
		"Agility":
			stats.strength = 7
			stats.endurance = 6
			stats.technique = 7
			stats.agility = 20
		_:
			# Default random
			stats.strength = randi_range(5, 15)
			stats.endurance = randi_range(5, 15)
			stats.technique = randi_range(5, 15)
			stats.agility = randi_range(5, 15)

	fighter.base_stats = stats

#endregion
