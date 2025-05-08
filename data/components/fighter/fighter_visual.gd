# res://data/components/fighter/fighter_visual.gd
class_name FighterVisual
extends Node

var sprite: Sprite2D
var animation_player: AnimationPlayer

func init(sprite_node: Sprite2D, animation_node: AnimationPlayer):
	sprite = sprite_node
	animation_player = animation_node

func flash_hit():
	if sprite:
		sprite.modulate = Color(1, 0.2, 0.2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

func play_attack(anim_name: String = "basic_punch"):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func is_playing_attack(anim_name: String = "basic_punch") -> bool:
	return animation_player and animation_player.is_playing() and animation_player.current_animation == anim_name
