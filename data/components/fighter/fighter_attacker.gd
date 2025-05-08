class_name FighterAttacker
extends Node

const BASE_ATTACK_COOLDOWN := 3.0

signal attack_hit_window

var get_total_stat: Callable
var get_tree_ref: Callable
var stamina_ref: Callable
var set_stamina: Callable
var attack_cooldown := 0.0

func init(
	_get_total_stat: Callable,
	_get_tree: Callable,
	_get_stamina: Callable,
	_set_stamina: Callable
):
	get_total_stat = _get_total_stat
	get_tree_ref = _get_tree
	stamina_ref = _get_stamina
	set_stamina = _set_stamina

func _process(delta: float) -> void:
	if attack_cooldown > 0:
		attack_cooldown -= delta

func reset_cooldown() -> void:
	attack_cooldown = get_attack_speed()

func get_attack_speed() -> float:
	var agility = get_total_stat.call("agility")
	return BASE_ATTACK_COOLDOWN / (1.0 + agility * 0.1)

func get_stamina_cost(on_hit: bool) -> int:
	return 10 if on_hit else 5

func check_attack_possible(on_hit: bool) -> int:
	if attack_cooldown > 0:
		return AttackResult.AttackCheckResult.COOLDOWN_ACTIVE
	if stamina_ref.call() < get_stamina_cost(on_hit):
		return AttackResult.AttackCheckResult.NOT_ENOUGH_STAMINA
	return AttackResult.AttackCheckResult.SUCCESS

func can_attack(on_hit: bool) -> bool:
	return check_attack_possible(on_hit) == AttackResult.AttackCheckResult.SUCCESS

func use_stamina(on_hit: bool) -> void:
	var cost = get_stamina_cost(on_hit)
	var new_stamina = max(0, stamina_ref.call() - cost)
	set_stamina.call(new_stamina)

func emit_hit_window() -> void:
	attack_hit_window.emit()
