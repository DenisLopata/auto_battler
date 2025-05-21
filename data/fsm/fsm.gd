class_name Fsm
extends Node

var states: Dictionary = {}
var current_state: FsmState
var current_state_id: int

var fighter: Fighter

func init() -> void:
	for child in get_children():
		if child is FsmState:
			var id = child.get_state_id()
			states[id] = child
			child.fsm = self
			child.fighter = fighter
	# Optionally start in IDLE state
	switch_state(FsmState.StateId.IDLE)

func switch_state(state_id: int) -> void:
	if current_state:
		current_state.exit()
	current_state_id = state_id
	current_state = states.get(state_id)
	if current_state:
		current_state.enter()

func _process(delta):
	if not current_state:
		return
		
	current_state.update(delta)

func _physics_process(delta):
	if not current_state:
		return
		
	current_state.physics_update(delta)
	
func is_in_state(state_id: int) -> bool:
	return current_state_id == state_id
	
func get_current_state_name() -> String:
	return current_state_id_to_string()

func current_state_id_to_string() -> String:
	match current_state_id:
		FsmState.StateId.IDLE:
			return "IDLE"
		FsmState.StateId.ATTACK:
			return "ATTACK"
		FsmState.StateId.MOVE:
			return "MOVE"
		FsmState.StateId.BLOCK:
			return "BLOCK"
		FsmState.StateId.RETREAT:
			return "RETREAT"
		_:
			return "UNKNOWN"
