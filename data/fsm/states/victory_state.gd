class_name VictoryState
extends FsmState

func get_state_id() -> int:
	return StateId.VICTORY

func enter():
	fighter.visuals.play("basic_victory")
	await fighter.visuals.animation_finished
	fighter.victory_animation_finished.emit(fighter)

func update(_delta: float) -> void:
	pass
