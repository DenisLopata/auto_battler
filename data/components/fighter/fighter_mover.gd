# res://data/components/fighter/fighter_mover.gd
class_name FighterMover
extends Node

var move_speed: float = 50.0
var owner_position: Callable  # Function to get the fighter's position
var set_position: Callable    # Function to update the fighter's position

func init(speed: float, get_position: Callable, update_position: Callable):
	move_speed = speed
	owner_position = get_position
	set_position = update_position

func move_toward(target_position: Vector2, delta: float) -> void:
	var direction = (target_position - owner_position.call()).normalized()
	var new_position = owner_position.call() + direction * move_speed * delta
	set_position.call(new_position)

func move_away(target_position: Vector2, delta: float, desired_distance: float = 200.0) -> void:
	var distance = owner_position.call().distance_to(target_position)
	if distance < desired_distance:
		var direction = (owner_position.call() - target_position).normalized()
		var new_position = owner_position.call() + direction * (move_speed / 2) * delta
		set_position.call(new_position)
