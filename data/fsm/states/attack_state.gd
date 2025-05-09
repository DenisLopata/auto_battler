class_name AttackState
extends FsmState

func get_state_id() -> int:
	return StateId.ATTACK

func enter():
	fighter.visuals.play("basic_punch")
	#fighter.mover.set_enabled(false)

	# Wait until animation finishes
	await fighter.visuals.animation_finished
	
	var context = fighter.context
	# Decide whether to idle or chase
	if fighter.fsm.is_in_state(StateId.ATTACK):
		if fighter.behavior.should_move(context):
			fsm.switch_state(StateId.MOVE)
		else:
			fsm.switch_state(StateId.IDLE)
