@icon("res://assets/icons/trait_icon.png") # optional

class_name FighterTrait
extends Resource

const FighterStats = preload("res://data/core/fighter_stats.gd")

@export var trait_id: String  # Unique identifier like "iron_will", "glass_cannon"
@export var display_name: String
@export var description: String
@export var icon: Texture2D

@export var stat_modifiers: FighterStats

@export var effect_tags: Array[String] = []  # e.g. ["low_hp_bonus", "anti_grappler"]
