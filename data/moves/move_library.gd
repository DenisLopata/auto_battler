# res://data/moves/move_library.gd
class_name MoveLibrary
extends Node

const MoveData = preload("res://data/core/move_data.gd")

func create_basic_punch() -> MoveData:
	var move = MoveData.new()
	move.name = "Basic Punch"
	move.animation_name = "basic_punch"
	move.animation_fps = 12
	move.startup_frames = 3
	move.active_frames = 2
	move.recovery_frames = 3
	move.damage = 10
	move.stamina_cost = 3
	move.knockback = 0.2
	move.causes_stagger = true
	move.can_be_blocked = true
	move.block_stun_frames = 3
	move.can_be_countered = true
	move.counter_window_start = 1
	move.counter_window_end = 3
	move.is_interruptible = true
	move.interruptible_start_frame = 0
	move.interruptible_end_frame = 3
	move.causes_camera_shake_on_hit = true
	move.causes_camera_slowmo_on_ko = false
	#move.tags = ["punch", "light", "close"]
	return move

func get_all_moves() -> Dictionary:
	return {
		"basic_punch": create_basic_punch(),
	}
