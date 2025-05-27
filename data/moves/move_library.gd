# res://data/moves/move_library.gd
class_name MoveLibrary
extends Node

const MoveData = preload("res://data/core/move_data.gd")

func create_basic_punch() -> MoveData:
	var move = MoveData.new()
	move.name = "Basic Punch"
	move.animation_name = "basic_punch"
	move.animation_fps = 30
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
	move.tags.clear()
	move.tags.append("punch")
	move.tags.append("light")
	move.tags.append("close")
	#move.tags = PackedStringArray(["punch", "light", "close"])  # or Array(["punch", "special", "close"])
	return move
	
func create_basic_special() -> MoveData:
	var move = MoveData.new()
	move.name = "Basic Special"
	move.animation_name = "basic_special"
	move.animation_fps = 30
	move.startup_frames = 8
	move.active_frames = 2
	move.recovery_frames = 3
	move.damage = 30
	move.stamina_cost = 0
	move.knockback = 0.5
	move.causes_stagger = true
	move.can_be_blocked = false
	move.block_stun_frames = 3
	move.can_be_countered = false
	move.counter_window_start = 0
	move.counter_window_end = 0
	move.is_interruptible = false
	move.interruptible_start_frame = 0
	move.interruptible_end_frame = 0
	move.causes_camera_shake_on_hit = true
	move.causes_camera_slowmo_on_ko = true
	#move.tags = ["punch", "special", "close"]
	#move.tags = PackedStringArray(["punch", "special", "close"])  # or Array(["punch", "special", "close"])
	move.tags.clear()
	move.tags.append("punch")
	move.tags.append("special")
	move.tags.append("close")
	return move

func get_all_moves() -> Dictionary:
	return {
		"basic_punch": create_basic_punch(),
	}
