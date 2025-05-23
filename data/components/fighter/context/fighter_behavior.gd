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
	var max_stamina: float = context.self_fighter.max_stamina.call()
	if context.self_fighter.stamina < max_stamina * 0.3:
		if randf() < 0.1:
			return true

	return false

func should_special(context: FighterContext) -> bool:
	var res = false
	
	var fighter: BaseFighter = context.self_fighter
	var special = fighter.special_meter
	var max_special = fighter.max_special()
	
	if special == max_special:
		res = true
	
	return res
	
func should_retreat(context: FighterContext) -> bool:
	var now = Time.get_ticks_msec() / 1000.0
	if now - context.last_retreat_time < context.retreat_cooldown:
		return false  # Still on cooldown
	
	var fighter: BaseFighter = context.self_fighter
	var opponent: BaseFighter = context.target_fighter
	
	var max_health = fighter.max_health()
	var health_ratio = float(fighter.health) / float(max_health)

	var max_stamina = fighter.max_stamina()
	var stamina_ratio = fighter.stamina / max_stamina
	
	var opponent_meter = opponent.special_meter / opponent.max_special()

	var retreat_weight = FighterPersonality.get_retreat_weight(fighter.personality)
	retreat_weight += FighterClasses.get_style_retreat_modifier(fighter.style)
	retreat_weight += fighter.get_trait_behavior_modifier()

	if health_ratio < 0.3:
		retreat_weight += 0.3
	if stamina_ratio < 0.2:
		retreat_weight += 0.2
	if opponent_meter > 0.6:
		retreat_weight += 0.2
	
	var decision = randf() < clamp(retreat_weight, 0.0, 1.0)

	if decision == true:
		pass
		#print_debug_retreat(context, retreat_weight, health_ratio, stamina_ratio, opponent_meter)

	return decision
	
func evaluate_intent(context: FighterContext) -> void:
	if not context.self_fighter or not context.target_fighter:
		context.intent.clear()
		return
		
	if not context.self_fighter.fight_is_active or not context.target_fighter.fight_is_active:
		context.intent.clear()
		return
		
	var fighter := context.self_fighter
	var intent := context.intent
	
	if should_special(context):
		intent.set_intent(IntentTypes.IntentType.SPECIAL, "Basic Special")
		return
		
	
	# Retreat has top priority
	if should_retreat(context):
		context.last_retreat_time = Time.get_ticks_msec() / 1000.0
		intent.set_intent(IntentTypes.IntentType.RETREAT)
		return
	
	# Only attack if we have a valid move
	if should_attack(context):
		var move := fighter.select_best_move(context)
		if move:
			intent.set_intent(IntentTypes.IntentType.ATTACK, move.name)
			return
	
	# Block if it makes sense
	if should_block(context):
		intent.set_intent(IntentTypes.IntentType.BLOCK)
		return
	
	# Move if we can and need to
	if should_move(context):
		intent.set_intent(IntentTypes.IntentType.MOVE, "", context.target_fighter.global_position)
		return
	
	# Otherwise idle
	intent.clear()
	
	
	
#region Test behaviour, not good still
func evaluate_intent_scores(context: FighterContext) -> void:
	if not context.self_fighter or not context.target_fighter:
		context.intent.clear()
		return

	var scores = {
		IntentTypes.IntentType.RETREAT: score_retreat(context),
		IntentTypes.IntentType.ATTACK: score_attack(context),
		IntentTypes.IntentType.BLOCK: score_block(context),
		IntentTypes.IntentType.MOVE: score_move(context),
		IntentTypes.IntentType.IDLE: 0.1,
	}

	var sorted_intents = scores.keys()
	sorted_intents.sort_custom(func(a, b): return scores[a] > scores[b])

	# 🧠 Debug: Print scores nicely
	var debug_msg := "[Fighter AI Scores] "
	for intent1 in scores:
		debug_msg += "%s: %.2f  " % [IntentTypes.get_type_string(intent1), scores[intent1]]
	print(debug_msg)
	
	var best_intent = sorted_intents[0]
	match best_intent:
		IntentTypes.IntentType.ATTACK:
			var move = context.self_fighter.select_best_move(context)
			if move:
				context.intent.set_intent(best_intent, move.name)
			else:
				context.intent.clear()
		IntentTypes.IntentType.MOVE:
			context.intent.set_intent(best_intent, "", context.target_fighter.global_position)
		_:
			context.intent.set_intent(best_intent)
			
func score_retreat(context: FighterContext) -> float:
	var f = context.self_fighter
	var t = context.target_fighter

	var health_ratio = f.health / f.max_health()
	var stamina_ratio = f.stamina / f.max_stamina()
	var distance = f.global_position.distance_to(t.global_position)
	var cornered = f.global_position.x < 100 or f.global_position.x > 1400

	var score = 0.0
	if health_ratio < 0.3:
		score += 0.5
	if stamina_ratio < 0.3:
		score += 0.3
	if distance < 200:
		score += 0.2
	if cornered:
		score -= 0.4  # Avoid retreating further into corner
	score -= 0.7
	return clamp(score, 0.0, 1.0)
	
func score_attack(context: FighterContext) -> float:
	var f = context.self_fighter
	var t = context.target_fighter

	var stamina_ratio = f.stamina / f.max_stamina()
	var distance = f.global_position.distance_to(t.global_position)

	var base = 0.0
	if stamina_ratio > 0.4:
		base += 0.4
	if distance < 150:
		base += 0.4
	#if t.just_missed_attack:  # You could add a flag from memory
		#base += 0.2

	return clamp(base, 0.0, 1.0)
	
func score_block(context: FighterContext) -> float:
	var f = context.self_fighter
	var t = context.target_fighter

	#var recent_attacks = f.memory.count_opponent_action("attack")  # Custom memory system
	var distance = f.global_position.distance_to(t.global_position)

	var score = 0.0
	#if recent_attacks > 3:
		#score += 0.3
	if distance < 100:
		score += 0.4
	#if t.is_mid_attack():  # Needs to be tracked
		#score += 0.3

	return clamp(score, 0.0, 1.0)
	
func score_move(context: FighterContext) -> float:
	var f = context.self_fighter
	var t = context.target_fighter

	var distance = f.global_position.distance_to(t.global_position)
	var score = 0.0

	if distance > 200:
		score += 0.6  # Close gap
	elif distance < 100:
		score += 0.2  # Create space, unless we're low stamina
	if f.stamina / f.max_stamina() < 0.2:
		score -= 0.2  # Don’t move too much if tired

	return clamp(score, 0.0, 1.0)

#endregion
	
func print_debug_retreat(context: FighterContext, weight: float, hp: float, stam: float, meter: float):
	print_rich("[color=orange][b]Retreat Decision:[/b][/color] %s" % context.self_fighter.fighter_name)
	print("  - HP Ratio: %.2f" % hp)
	print("  - Stamina Ratio: %.2f" % stam)
	print("  - Opponent Special: %.2f" % meter)
	print("  - Weight: %.2f → Decision: %s" % [weight, weight > 0.5])
