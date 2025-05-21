extends Node

signal fight_started
signal fight_ended

@export var fighter_scene: PackedScene

var arena_controller: Node
var hud_left: FighterHUD
var hud_right: FighterHUD
var start_button: Button
var camera_rig: Node2D

var fighter_left: Fighter = null
var fighter_right: Fighter = null

func setup(arena: Node, left_hud: FighterHUD, right_hud: FighterHUD, button: Button, camera_rig: Node2D):
	arena_controller = arena
	hud_left = left_hud
	hud_right = right_hud
	start_button = button
	start_button.pressed.connect(_on_start_pressed)
	start_button.disabled = false
	
	arena_controller.fight_ended.connect(_on_fight_ended)
	arena_controller.camera_rig = camera_rig

func _on_start_pressed():
	start_button.disabled = true
	start_fight()

func start_fight():
	clear_fighters()

	# Create and track fighters
	fighter_left = fighter_scene.instantiate()
	fighter_right = fighter_scene.instantiate()

	fighter_left.fighter_name = get_random_name()
	fighter_right.fighter_name = get_random_name()
	
	randomize_stats(fighter_left)
	randomize_stats(fighter_right)
	
	#debug stats
	#fighter_left.base_stats.endurance = 1
	#fighter_left.base_stats.agility = 1
	
	# Add to scene
	add_child(fighter_left)
	add_child(fighter_right)
	
	# Place them
	fighter_left.position = Vector2(200, 150)
	fighter_right.position = Vector2(400, 150)
	
	#rotate sprite
	fighter_right.flip_sprite(true)
	
	# Connect them
	arena_controller.set_fighters(fighter_left, fighter_right)
	
	hud_left.fighters = [fighter_left]
	hud_right.fighters = [fighter_right]
	
	hud_left._initialize_ui()
	hud_right._initialize_ui()
	
	fighter_left.context.target_fighter = fighter_right
	fighter_right.context.target_fighter = fighter_left
	
	# Start the fight
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

var name_pool = ["Crusher", "Steel Fist", "Iron Jaw", "Quickstep", "Shadow", "Bruiser", "Rage", "Ghost", "Blitz", "The Wall"]

func get_random_name() -> String:
	return name_pool[randi() % name_pool.size()]
	
func randomize_stats(fighter: Fighter):
	var stats := FighterStats.new()
	stats.strength = randi_range(5, 15)
	stats.endurance = randi_range(5, 15)
	stats.technique = randi_range(5, 15)
	stats.agility = randi_range(5, 15)
	fighter.base_stats = stats


#endregion
