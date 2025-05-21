# FighterBehavior.gd
class_name FighterBehavior
extends RefCounted


static func should_retreat_old(fighter: BaseFighter, opponent: BaseFighter) -> bool:
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
