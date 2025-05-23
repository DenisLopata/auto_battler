class_name HitState
extends FsmState

func get_state_id() -> int:
	return StateId.HIT

func enter():
	
	fighter.visuals.play("basic_hit")
	fighter.visuals.flash_hit()
	
	await fighter.visuals.animation_finished
	
	var opponent_fsm = fighter.context.target_fighter.fsm
	var is_op_in_special = opponent_fsm.is_in_state(StateId.SPECIAL)
	
	#if op is in special, remain hit
	if is_op_in_special:
		return
		
	# Transition back to a sensible state
	if fighter.fsm.is_in_state(StateId.HIT):
		if fighter.behavior.should_move(fighter.context):
			fsm.switch_state(StateId.MOVE)
		else:
			fsm.switch_state(StateId.IDLE)

func update(delta: float) -> void:
	var opponent_fsm = fighter.context.target_fighter.fsm
	var is_op_in_special = opponent_fsm.is_in_state(StateId.SPECIAL)
	
	#if op is in special, remain hit
	if is_op_in_special:
		return
		
	# Transition back to a sensible state
	if fighter.fsm.is_in_state(StateId.HIT):
		if fighter.behavior.should_move(fighter.context):
			fsm.switch_state(StateId.MOVE)
		else:
			fsm.switch_state(StateId.IDLE)
