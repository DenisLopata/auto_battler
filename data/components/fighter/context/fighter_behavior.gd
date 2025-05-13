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

func should_block(context: FighterContext) -> bool:
	var opponent := context.target_fighter
	if opponent == null or opponent.context.intent == null:
		return false
	
	var incoming_intent := opponent.context.intent
	var incoming_type := incoming_intent.type

	# Predict incoming attack
	if incoming_type == IntentTypes.IntentType.ATTACK:
		var distance := context.distance_to_target
		if distance < 60.0:  # Adjust based on hitbox/melee range
			return true

	# Maybe block if low stamina and expecting aggression
	#if context.self_fighter.stamina < context.self_fighter.max_stamina * 0.3:
		#if randf() < 0.1:
			#return true

	return false

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
	
func evaluate_intent(context: FighterContext) -> void:
	if not context.self_fighter or not context.target_fighter:
		context.intent.clear()
		return
		
	var fighter := context.self_fighter
	var intent := context.intent

	# Simple decision logic (you’ll refine this later)
	if should_retreat(context):
		intent.set_intent(IntentTypes.IntentType.RETREAT)
	elif should_block(context):
		intent.set_intent(IntentTypes.IntentType.BLOCK)
	elif should_attack(context):
		var move := fighter.select_best_move(context)
		intent.set_intent(IntentTypes.IntentType.ATTACK, move.name)
	elif should_move(context):
		intent.set_intent(IntentTypes.IntentType.MOVE, "", context.target_fighter.global_position)
	else:
		intent.clear()
