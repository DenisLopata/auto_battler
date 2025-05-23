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
		#if anim_name == "basic_punch" or anim_name == "basic_special":
			#add_function_call_to_animation(anim_name, "nim_fun", 8)
			
			
		#var anim = animation_player.get_animation(anim_name)
		#var track_index = anim.find_track("function_call",Animation.TYPE_METHOD)
		#if track_index == -1:
			#track_index = anim.add_track(Animation.TYPE_METHOD)
		#
		#anim.track_set_path(track_index, ".")	
		#
		#var frame = 8
		#var method_name = ""
		#var args = ""
		## Convert frame to time based on FPS
		#var time = frame / anim.step
		#anim.track_insert_key(track_index, time, {
			#"method": method_name,
			#"args": args
		#})
		
		var qu = animation_player.get_queue()
		animation_player.play(anim_name)
	elif not animation_player.has_animation(anim_name):
		#default animation if nothing found
		animation_player.play("basic_idle")
		
func add_function_call_to_animation(anim_name: String, method_name: String, frame: int, args: Array = []):
	var anim = animation_player.get_animation(anim_name)
	if not anim:
		print("Animation not found:", anim_name)
		return
	frame = 4
	var time = frame / anim.step
	
	var track_index = -1
	# Try to find existing method track calling on "."
	for i in anim.get_track_count():
		var path = str(anim.track_get_path(i))
		var type = anim.track_get_type(i)
		if anim.track_get_type(i) == Animation.TYPE_METHOD and path == ".":
			track_index = i
			break
	
	# If not found, create it
	if track_index == -1:
		track_index = anim.add_track(Animation.TYPE_METHOD)
		anim.track_set_path(track_index, ".")
	else:
		var cnt = anim.track_get_key_count(track_index)
		for i in cnt:
			var val = anim.track_get_key_value(track_index, i)
			pass
	method_name = "emit_attack_hit_window"
	anim.track_insert_key(track_index, time, {
		"method": method_name,
		"args": args
	})

func play_attack(anim_name: String = "basic_punch"):
	if animation_player and animation_player.has_animation(anim_name):
		animation_player.play(anim_name)

func is_playing_attack(anim_name: String = "basic_punch") -> bool:
	return animation_player and animation_player.is_playing() and animation_player.current_animation == anim_name

func get_current_frame() -> int:
	if sprite.frame:
		var frame = sprite.frame
		return frame
	return -1  # Return -1 if animation is not playing or not found

func _on_animation_finished(anim_name: String):
	animation_finished.emit()
	
