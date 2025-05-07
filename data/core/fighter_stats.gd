class_name FighterStats
extends Resource

@export var strength: int = 0
@export var agility: int = 0
@export var endurance: int = 0
@export var technique: int = 0


func add(other: FighterStats) -> FighterStats:
	var result = FighterStats.new()
	result.strength = self.strength + other.strength
	result.agility = self.agility + other.agility
	result.endurance = self.endurance + other.endurance
	result.technique = self.technique + other.technique
	return result
