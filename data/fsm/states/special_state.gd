class_name SpecialState
extends FsmState

func get_state_id() -> int:
	return StateId.SPECIAL
	
func enter() -> void:
	var context = fighter.context
	var intent: FighterIntent = context.intent
	
	SignalBus.special_mode_started.emit(fighter)
	
	# Show anticipation on opponent
	#if context.target_fighter:
		#fighter.opponent.play_anticipation_animation()
	
	var move: MoveData = null
	
	# Prefer move from intent
	if intent.move_name != "":
		move = fighter.get_move_by_name(intent.move_name)
		
	# Play the special move
	fighter.visuals.play(move.animation_name)
	fighter.move_controller.start_move(move, fighter.visuals)
	fighter.context.target_fighter.fsm.switch_state(StateId.SPECIAL_PASSIVE)
	
	await fighter.visuals.animation_finished
	fighter.special_meter = 0
	
	# Refresh context and intent after attack
	context.update(fighter)
	if fighter.fsm.is_in_state(StateId.SPECIAL):
		match context.intent.type:
			IntentTypes.IntentType.MOVE:
				fsm.switch_state(StateId.MOVE)
			IntentTypes.IntentType.RETREAT:
				fsm.switch_state(StateId.MOVE)  # Or RETREAT if separate
			IntentTypes.IntentType.BLOCK:
				fsm.switch_state(StateId.BLOCK)
			_:
				fsm.switch_state(StateId.IDLE)
	

func exit() -> void:
	SignalBus.special_mode_ended.emit(fighter)
	pass
