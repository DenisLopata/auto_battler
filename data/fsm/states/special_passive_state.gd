class_name SpecialPassiveState
extends FsmState

func get_state_id() -> int:
	return StateId.SPECIAL_PASSIVE
	
func enter():
	
	fighter.visuals.play("basic_special_passive")
	#fighter.visuals.flash_hit()
	
	await fighter.visuals.animation_finished
	
	## Transition back to a sensible state
	#if fighter.fsm.is_in_state(StateId.SPECIAL_PASSIVE):
		#if fighter.behavior.should_move(fighter.context):
			#fsm.switch_state(StateId.MOVE)
		#else:
			#fsm.switch_state(StateId.IDLE)
