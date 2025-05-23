class_name MoveController
extends Node

signal move_finished(move: MoveData)
signal attack_window_started(move: MoveData)


var current_move: MoveData
var current_frame := 0
var frame_timer := 0.0
var is_active := false
var has_emitted_attack_window := false
var current_visuals = FighterVisual

func start_move(move: MoveData, visuals: FighterVisual):
	current_move = move
	current_frame = 0
	frame_timer = 0.0
	is_active = true
	has_emitted_attack_window = false
	current_visuals = visuals

func update(delta: float):
	#this does not calculate frames correct
	return
	if not is_active or current_move == null:
		return
	
	var anim_frame = current_visuals.get_current_frame()
	print("anim_frame: " + str(anim_frame))
	# Advance frame timer
	frame_timer += delta
	var frame_duration = 1.0 / current_move.animation_fps
	
	# Advance one or more frames depending on timer
	while frame_timer >= frame_duration:
		frame_timer -= frame_duration
		current_frame += 1
		_check_frame_events()

		# Check if move is finished
		var total_frames = current_move.startup_frames + current_move.active_frames + current_move.recovery_frames
		if current_frame >= total_frames:
			is_active = false
			move_finished.emit(current_move)
			break

func _check_frame_events():
	var start = current_move.startup_frames

	var anim_frame = current_visuals.get_current_frame()
	# Trigger only once when entering active window
	if not has_emitted_attack_window and current_frame == start:
		has_emitted_attack_window = true
		attack_window_started.emit(current_move)
