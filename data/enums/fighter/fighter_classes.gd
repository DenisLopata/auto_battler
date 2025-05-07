class_name FighterClasses
extends RefCounted

enum FighterStyle {
	BRAWLER,
	GRAPPLER,
	COUNTER,
	SPEEDSTER,
	BALANCED
}

static func get_style_retreat_modifier(style: int) -> float:
	match style:
		FighterStyle.BRAWLER:
			return -0.1
		FighterStyle.GRAPPLER:
			return -0.05
		FighterStyle.COUNTER:
			return 0.2
		FighterStyle.SPEEDSTER:
			return 0.3
		FighterStyle.BALANCED:
			return 0.0
		_:
			return 0.0
