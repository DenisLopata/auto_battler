class_name BlockState
extends FsmState

func get_state_id() -> int:
	return StateId.BLOCK

func enter():
	fighter.visuals.play("basic_block")  # Replace with actual block animation name
	fighter.is_blocking = true

func exit():
	fighter.is_blocking = false

func update(delta: float) -> void:
	var context = fighter.context

	# If no longer intending to block, decide next action
	if context.intent.type != IntentTypes.IntentType.BLOCK:
		if fighter.behavior.should_attack(context):
			fsm.switch_state(StateId.ATTACK)
		elif fighter.behavior.should_retreat(context):
			fsm.switch_state(StateId.RETREAT)
		elif fighter.behavior.should_move(context):
			fsm.switch_state(StateId.MOVE)
		else:
			fsm.switch_state(StateId.IDLE)
