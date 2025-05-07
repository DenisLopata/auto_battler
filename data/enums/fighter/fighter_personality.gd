# data/fighter_personality.gd
class_name FighterPersonality
extends RefCounted

enum Personality {
	AGGRESSIVE,
	DEFENSIVE,
	NEUTRAL,
	CHAOTIC
}

static func get_retreat_weight(personality: int) -> float:
	match personality:
		Personality.AGGRESSIVE:
			return 0.1
		Personality.DEFENSIVE:
			return 0.5
		Personality.NEUTRAL:
			return 0.3
		Personality.CHAOTIC:
			return randf_range(0.0, 0.6)
		_:
			return 0.3
