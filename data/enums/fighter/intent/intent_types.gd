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
	COMBO
}

static func get_type_string(intent_type: IntentType) -> String:
	match intent_type:
		IntentType.RETREAT: return "Retreat"
		IntentType.ATTACK: return "Attack"
		IntentType.BLOCK: return "Block"
		IntentType.MOVE: return "Move"
		IntentType.IDLE: return "Idle"
		_: return "Unknown"
