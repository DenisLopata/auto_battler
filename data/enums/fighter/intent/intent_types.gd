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
