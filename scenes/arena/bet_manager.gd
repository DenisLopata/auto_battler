# res://scenes/arena/bet_manager.gd
class_name BetManager
extends Node

signal bet_confirmed(fighter: Fighter)
signal score_changed(new_score: int)

var chosen_fighter: Fighter = null
var total_score := 0
var lose_penalty := -1
var win_reward := 1
var is_bet_locked: bool = false

func place_bet(fighter: Fighter) -> void:
	if is_bet_locked:
		return
	chosen_fighter = fighter
	is_bet_locked = true
	bet_confirmed.emit(fighter)

func reset_bet() -> void:
	chosen_fighter = null
	is_bet_locked = false

func update_score(winning_fighter: Fighter) -> void:
	if chosen_fighter == null:
		return
	
	if winning_fighter == chosen_fighter:
		total_score += win_reward
		print("Correct bet! Total score: %d" % total_score)
	else:
		total_score += lose_penalty
		print("Wrong bet. Total score: %d" % total_score)
	
	chosen_fighter = null
	
	score_changed.emit(total_score)

	reset_bet()
