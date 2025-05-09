# res://data/components/fighter/context/fighter_behavior.gd
class_name FighterBehaviorContext
extends Resource

func should_move(context: FighterContext) -> bool:
	var res =  context.distance_to_target > context.self_fighter.attack_range and not context.is_retreating
	return res

func should_attack(context: FighterContext) -> bool:
	var res = context.distance_to_target <= context.self_fighter.attack_range and context.attack_cooldown <= 0
	return res

#func should_retreat(context: FighterContext) -> bool:
	#return context.current_hp < (context.max_hp * 0.3)

func should_retreat_simple(context: FighterContext) -> bool:
	return context.is_retreating or context.current_hp < context.max_hp * 0.3
	
func is_retreating(context: FighterContext) -> bool:
	var should_retreat = should_retreat_simple(context)
	return context.is_retreating or should_retreat

func wants_to_approach(context: FighterContext) -> bool:
	return context.distance_to_target > context.self_fighter.attack_range and not is_retreating(context)


func should_retreat(context: FighterContext) -> bool:
	var fighter: BaseFighter = context.self_fighter
	var opponent: BaseFighter = context.target_fighter
	
	var max_health = fighter.max_health()
	var health_ratio = float(fighter.health) / float(max_health)

	var max_stamina = fighter.max_stamina()
	var stamina_ratio = fighter.stamina / max_stamina

	var retreat_weight = FighterPersonality.get_retreat_weight(fighter.personality)
	retreat_weight += FighterClasses.get_style_retreat_modifier(fighter.style)
	retreat_weight += fighter.get_trait_behavior_modifier()

	if health_ratio < 0.3:
		retreat_weight += 0.3
	if stamina_ratio < 0.2:
		retreat_weight += 0.2
	
	var res = randf() < clamp(retreat_weight, 0.0, 1.0)
	return res
	
