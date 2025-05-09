class_name FsmState
extends Node

enum StateId {
	IDLE,
	MOVE,
	ATTACK,
	HIT,
	DEAD,
	VICTORY
}

var fsm: Fsm
var fighter: Fighter

func get_state_id() -> int:
	push_error("Override get_state_id() in " + str(self))
	return -1
	
func enter() -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass
