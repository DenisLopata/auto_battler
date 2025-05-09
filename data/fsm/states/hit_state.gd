class_name HitState
extends FsmState

func get_state_id() -> int:
	return StateId.HIT

func enter():
	
	fighter.visuals.play("basic_hit")
	fighter.visuals.flash_hit()
	
	await fighter.visuals.animation_finished
	#await get_tree().create_timer(0.2).timeout
	
	# Transition back to a sensible state
	if fighter.fsm.is_in_state(StateId.HIT):
		if fighter.behavior.should_move(fighter.context):
			fsm.switch_state(StateId.MOVE)
		else:
			fsm.switch_state(StateId.IDLE)
