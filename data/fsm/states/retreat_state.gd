class_name RetreatState
extends FsmState

func get_state_id() -> int:
	return StateId.RETREAT

func enter():
	#fighter.visuals.play("basic_retreat")  
	fighter.visuals.play("basic_run")

func update(delta: float) -> void:
	var context = fighter.context
	var target = context.target_fighter

	# End retreat if intent has changed
	if context.intent.type != IntentTypes.IntentType.RETREAT:
		if fighter.behavior.should_attack(context):
			fsm.switch_state(StateId.ATTACK)
		elif fighter.behavior.should_move(context):
			fsm.switch_state(StateId.MOVE)
		else:
			fsm.switch_state(StateId.IDLE)
		return

	# Still retreating
	fighter.mover.move_away(target.global_position, delta)
