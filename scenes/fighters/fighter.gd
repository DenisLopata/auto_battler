class_name Fighter
extends BaseFighter


func _ready() -> void:
	
	self.base_stats.endurance = 10
	
	#stamina
	self.base_stats.agility = 100
	
	#special
	self.base_stats.technique = 10
	self.special_meter = 4
	
	#strength
	self.base_stats.strength = 10
	super._ready()

func receive_damage(amount: int):
	health = max(health - amount, 0)
	health_changed.emit()
