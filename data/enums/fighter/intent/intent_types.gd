# res://data/enums/fighter/intent/intent_types.gd
class_name IntentTypes
extends RefCounted

enum IntentType {
	NONE,
	ATTACK,
	BLOCK,
	RETREAT,
	MOVE,
	IDLE,
	COUNTER,
	COMBO,
	SPECIAL,
	SPECIAL_PASSIVE
}

static func get_type_string(intent_type: IntentType) -> String:
	match intent_type:
		IntentType.ATTACK: return "Attack"
		IntentType.BLOCK: return "Block"
		IntentType.RETREAT: return "Retreat"
		IntentType.MOVE: return "Move"
		IntentType.IDLE: return "Idle"
		IntentType.COUNTER: return "Counter"
		IntentType.COMBO: return "Combo"
		IntentType.SPECIAL: return "Special"
		IntentType.SPECIAL_PASSIVE: return "Special_Passive"
		_: return "Unknown"
