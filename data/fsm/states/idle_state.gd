class_name IdleState
extends FsmState

func get_state_id() -> int:
	return StateId.IDLE

func enter():
	fighter.visuals.play("basic_idle")
	var context = fighter.context
	context.is_retreating = false

func update(_delta: float) -> void:
	var intent := fighter.context.intent

	match intent.type:
		IntentTypes.IntentType.RETREAT:
			fsm.switch_state(StateId.MOVE)  # Or StateId.RETREAT if separate
		IntentTypes.IntentType.ATTACK:
			fsm.switch_state(StateId.ATTACK)
		IntentTypes.IntentType.MOVE:
			fsm.switch_state(StateId.MOVE)
		IntentTypes.IntentType.BLOCK:
			fsm.switch_state(StateId.BLOCK)
		IntentTypes.IntentType.SPECIAL:
			fsm.switch_state(StateId.SPECIAL)
		_:
			pass  # Remain in Idle
	#
#func update(_delta: float) -> void:
	#var context = fighter.context
	#
	#if fighter.behavior.should_retreat(context):
		#print("retreat")
		#context.is_retreating = true
		#fsm.switch_state(StateId.MOVE)  # or RETREAT if separated
	#elif fighter.behavior.should_move(context):
		#fsm.switch_state(StateId.MOVE)
	#elif fighter.behavior.should_attack(context):
		#fsm.switch_state(StateId.ATTACK)
