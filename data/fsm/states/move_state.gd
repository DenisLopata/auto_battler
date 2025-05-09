class_name MoveState
extends FsmState

func get_state_id() -> int:
	return StateId.MOVE

func enter() -> void:
	fighter.visuals.play("basic_idle")

func update(delta: float) -> void:
	var context = fighter.context
	var target = context.target_fighter
	
	if fighter.behavior.should_attack(context):
		fsm.switch_state(StateId.ATTACK)
		return
	elif not fighter.behavior.should_move(context):
		fsm.switch_state(StateId.IDLE)
		return

	if fighter.behavior.is_retreating(context):
		fighter.mover.move_away(target.global_position, delta)
	else:
		fighter.mover.move_toward(target.global_position, delta)
