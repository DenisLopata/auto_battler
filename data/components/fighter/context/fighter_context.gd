# res://data/components/fighter/context/fighter_context.gd
class_name FighterContext
extends Resource

var self_fighter: BaseFighter
var target_fighter: BaseFighter

var distance_to_target := 0.0
var attack_cooldown := 0.0
var is_retreating := false
var current_hp := 0
var max_hp := 0

func update() -> void:
	if self_fighter and target_fighter:
		distance_to_target = self_fighter.global_position.distance_to(target_fighter.global_position)
		attack_cooldown = self_fighter.attack_cooldown
		current_hp = self_fighter.health
		max_hp = self_fighter.max_health()
