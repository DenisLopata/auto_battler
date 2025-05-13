class_name MoveState
extends FsmState

func get_state_id() -> int:
	return StateId.MOVE

func enter() -> void:
	fighter.visuals.play("basic_run")

func update(delta: float) -> void:
	var context = fighter.context
	var intent: FighterIntent = context.intent
	var target = context.target_fighter
	
	
	match intent.type:
		IntentTypes.IntentType.ATTACK:
			fsm.switch_state(StateId.ATTACK)
		IntentTypes.IntentType.IDLE:
			fsm.switch_state(StateId.IDLE)
		IntentTypes.IntentType.RETREAT:
			fsm.switch_state(StateId.RETREAT)
		IntentTypes.IntentType.MOVE:
			fighter.mover.move_toward(intent.target_position, delta)
		_:
			#fighter.mover.stop()  # Optional: stop or keep moving forward
			fsm.switch_state(StateId.IDLE)
	
	#if fighter.behavior.should_attack(context):
		#fsm.switch_state(StateId.ATTACK)
		#return
	#elif not fighter.behavior.should_move(context):
		#fsm.switch_state(StateId.IDLE)
		#return
#
	#if fighter.behavior.is_retreating(context):
		#fighter.mover.move_away(target.global_position, delta)
	#else:
		#fighter.mover.move_toward(target.global_position, delta)
