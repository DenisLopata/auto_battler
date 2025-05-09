# res://data/components/fighter/fighter_visual.gd
class_name FighterVisual
extends Node

signal animation_finished

var animation_data := {
	"basic_idle": { "loop": true, "speed": 1.0 },
	"basic_run": { "loop": true, "speed": 1.0 },
	"basic_punch": { "loop": false, "speed": 1.0 },
	"basic_hit": { "loop": false, "speed": 1.0 },
	"basic_death": { "loop": true , "speed": 1.0 }
}

var sprite: Sprite2D
var animation_player: AnimationPlayer

func init(sprite_node: Sprite2D, animation_node: AnimationPlayer) -> void:
	sprite = sprite_node
	animation_player = animation_node
	
	if animation_player:
		animation_player.animation_finished.connect(_on_animation_finished)

func flash_hit():
	if sprite:
		sprite.modulate = Color(1, 0.2, 0.2)
		await get_tree().create_timer(0.1).timeout
		sprite.modulate = Color(1, 1, 1)

func play(anim_name: String) -> void:
	if not animation_player or not animation_player.has_animation(anim_name):
		return
	
	var meta = animation_data.get(anim_name, {})
	var should_loop = meta.get("loop", false)
	var speed = meta.get("speed", 1.0)
		
	if animation_player and animation_player.has_animation(anim_name):
		#var loop = animation_data.get(anim_name, {}).get("loop", false)
		#var anim := animation_player.get_animation(anim_name)
		#if loop:
			#anim.loop_mode = Animation.LOOP_LINEAR
		#else:
			#anim.loop_mode = Animation.LOOP_NONE
		var qu = animation_player.get_queue()
		animation_player.play(anim_name)
	elif not animation_player.has_animation(anim_name):
		#default animation if nothing found
		animation_player.play("basic_idle")

func play_attack(anim_name: String = "basic_punch"):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func is_playing_attack(anim_name: String = "basic_punch") -> bool:
	return animation_player and animation_player.is_playing() and animation_player.current_animation == anim_name

func _on_animation_finished(anim_name: String):
	animation_finished.emit()
	
