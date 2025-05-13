# res://data/components/fighter/intent/fighter_intent.gd
class_name FighterIntent
extends Resource

@export var type: IntentTypes.IntentType = IntentTypes.IntentType.NONE
@export var target_position: Vector2 = Vector2.ZERO
@export var move_name: String = ""
@export var timestamp: float = 0.0  # Optional, can be used for fading/priority logic

func set_intent(type: IntentTypes.IntentType, move_name := "", target_position := Vector2.ZERO):
	self.type = type
	self.move_name = move_name
	self.target_position = target_position
	self.timestamp = Time.get_ticks_msec() / 1000.0

func clear():
	set_intent(IntentTypes.IntentType.NONE)
