# res://data/enums/fighter/attack_result.gd
class_name AttackResult
extends RefCounted

enum AttackCheckResult {
	SUCCESS,
	NOT_ENOUGH_STAMINA,
	COOLDOWN_ACTIVE
}
