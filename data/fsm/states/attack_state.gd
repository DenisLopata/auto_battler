class_name AttackState
extends FsmState

func get_state_id() -> int:
	return StateId.ATTACK


func enter():
	var context = fighter.context
	var intent: FighterIntent = context.intent

	var move: MoveData = null

	# Prefer move from intent
	if intent.move_name != "":
		move = fighter.get_move_by_name(intent.move_name)
	
	# Fallback to best move
	if move == null:
		move = fighter.select_best_move(context)

	if move == null:
		push_error("No valid move found for attack!")
		fsm.switch_state(StateId.IDLE)
		return

	fighter.visuals.play(move.animation_name)
	fighter.move_controller.start_move(move)

	await fighter.visuals.animation_finished

	# Refresh context and intent after attack
	context.update(fighter)
	if fighter.fsm.is_in_state(StateId.ATTACK):
		match context.intent.type:
			IntentTypes.IntentType.MOVE:
				fsm.switch_state(StateId.MOVE)
			IntentTypes.IntentType.RETREAT:
				fsm.switch_state(StateId.MOVE)  # Or RETREAT if separate
			IntentTypes.IntentType.BLOCK:
				fsm.switch_state(StateId.BLOCK)
			_:
				fsm.switch_state(StateId.IDLE)

#func enter():
	#var move = fighter.default_move
	#fighter.visuals.play(move.animation_name)
	#fighter.move_controller.start_move(move)
	#
	#await fighter.visuals.animation_finished
	#
	##fighter.visuals.play("basic_punch")
##
	### Wait until animation finishes
	##await fighter.visuals.animation_finished
	#
	#var context = fighter.context
	## Decide whether to idle or chase
	#if fighter.fsm.is_in_state(StateId.ATTACK):
		#if fighter.behavior.should_move(context):
			#fsm.switch_state(StateId.MOVE)
		#else:
			#fsm.switch_state(StateId.IDLE)
