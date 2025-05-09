class_name DeadState
extends FsmState

func get_state_id() -> int:
	return StateId.DEAD

func enter():
	fighter.visuals.play("basic_death")

func update(_delta: float) -> void:
	pass
