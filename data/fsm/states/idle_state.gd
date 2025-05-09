class_name IdleState
extends FsmState

func get_state_id() -> int:
	return StateId.IDLE

func enter():
	fighter.visuals.play("basic_idle")
	var context = fighter.context
	context.is_retreating = false

#func update(_delta):
	#if fighter.should_move():
		#fsm.switch_state(StateId.MOVE)
	#elif fighter.should_attack():
		#fsm.switch_state(StateId.ATTACK)
		
func update(_delta: float) -> void:
	var context = fighter.context
	
	if fighter.behavior.should_retreat(context):
		context.is_retreating = true
		fsm.switch_state(StateId.MOVE)  # or RETREAT if separated
	elif fighter.behavior.should_move(context):
		fsm.switch_state(StateId.MOVE)
	elif fighter.behavior.should_attack(context):
		fsm.switch_state(StateId.ATTACK)
