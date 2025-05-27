class_name ArenaController
extends Node

signal fight_ended(winner: Fighter, loser: Fighter)
signal fighters_ready(fighter_left: Fighter, fighter_right: Fighter)

var fight_over := false

var fighter_left: Fighter = null
var fighter_right: Fighter = null

var camera_rig: Node2D
var background_image: TextureRect
var background_overlay: TextureRect

func _end_fight(winner: Fighter):
	print("Battle Over! Winner: %s" % winner.fighter_name)
	# Optional: trigger animations, end UI, etc.
	
		
func set_fighters(left: Fighter, right: Fighter):
	fighter_left = left
	fighter_right = right
	fight_over = false
	
	left.attack_hit_window.connect(_on_attack_hit_window)
	right.attack_hit_window.connect(_on_attack_hit_window)
	
	left.victory_animation_finished.connect(_on_victory_animation_finished)
	right.victory_animation_finished.connect(_on_victory_animation_finished)
	
	fighters_ready.emit(fighter_left, fighter_right)
	
func start_fight():
	fight_over = false
	fighter_left.fight_is_active = true
	fighter_right.fight_is_active = true

func try_attack(attacker: Fighter, defender: Fighter):
	var on_hit = true
	var result = attacker.check_attack_possible(on_hit)
	if result != AttackResult.AttackCheckResult.SUCCESS:
		match result:
			AttackResult.AttackCheckResult.COOLDOWN_ACTIVE:
				#print("%s is cooling down!" % attacker.fighter_name)
				pass
			AttackResult.AttackCheckResult.NOT_ENOUGH_STAMINA:
				#print("%s is too tired to attack!" % attacker.fighter_name)
				pass
		return
	
	# Trigger animation
	attacker.play_attack_animation()


func end_fight(winner: Fighter, loser: Fighter):
	if fight_over:
		return
	fight_over = true
	
	winner.fight_is_active = false
	loser.fight_is_active = false
	
	print("%s is defeated! %s wins!" % [loser.fighter_name, winner.fighter_name])
	fight_ended.emit(winner, loser)

	# Optional: freeze inputs, slow motion, trigger animations, show victory screen, etc.
	
func does_attack_hit(attacker: Fighter, defender: Fighter) -> bool:
	var atk_technique = attacker.get_total_stat("technique")
	var def_agility = defender.get_total_stat("agility")
	var hit_chance = 0.75 + (atk_technique - def_agility) * 0.02	
	var rand = randf()
	var chance = clamp(hit_chance, 0.1, 0.95)
	var res = rand < chance
	return res

func calculate_damage(attacker: Fighter, defender: Fighter) -> int:
	var current_move: MoveData = attacker.move_controller.current_move
	if not current_move:
		return 1  # fallback if no move data
	
	# Extract stats
	var strength = attacker.get_total_stat("strength")
	var endurance = defender.get_total_stat("endurance")

	# Move and stat influence
	var move_dmg = current_move.damage
	var strength_mult = 0.5
	var reduction = endurance * 0.5

	# Special multiplier
	var special_mult = 1.0
	if "special" in current_move.tags:
		special_mult = 1.0  # or 1.5 if you prefer less burst

	# Final damage formula
	var raw_damage = (move_dmg + strength * strength_mult) * special_mult
	var final_damage = max(1, int(raw_damage - reduction))

	return final_damage

#
#func calculate_damage(attacker: Fighter, defender: Fighter) -> int:
	#var base = attacker.get_total_stat("strength") * 2
	#var reduction = defender.get_total_stat("endurance") * 0.5
	#
	##we need to implement this logic
	#var current_move: MoveData = attacker.move_controller.current_move
	#if current_move:
		#var move_dmg = current_move.damage
		#var is_special = false
		#if "special" in current_move.tags:
			#is_special = true
	#
	#var res =  max(1, base - reduction)
	#return res

func show_miss_effect() -> void:
	print("Attack missed!")
	
	
func _on_victory_animation_finished(attacker: BaseFighter) -> void:
	#TODO display win screen and so on
	#show_win_screen()
	pass
	
func _on_attack_hit_window(attacker: Fighter, move: MoveData):
	var defender = fighter_right if attacker == fighter_left else fighter_left
	
	var does_hit = false
	if "special" in move.tags:
		does_hit = true
	else:
		does_hit = does_attack_hit(attacker, defender)
	if does_hit:
		var damage = calculate_damage(attacker, defender)
		var was_blocked: = defender.apply_damage(damage)
		
		attacker.add_special(2)
		if was_blocked:
			defender.add_special(10)
		else:	
			defender.add_special(0.5)
		
		camera_rig.punch_zoom_effect(0.4)
		#var default_move = attacker.default_move
		if  move.causes_camera_slowmo_on_ko:
			trigger_slowmo(move.slowmo_duration, move.slowmo_timescale)


		print(attacker.name, " hit ", defender.name, " for ", damage)
		attacker.use_stamina(true)
		
		if defender.health <= 0:
			defender.on_death()
			attacker.fsm.switch_state(FsmState.StateId.VICTORY)
			end_fight(attacker, defender)
	else:
		show_miss_effect()
		print(attacker.name, " missed!")
		attacker.use_stamina(false)

	attacker.reset_attack_cooldown()

func trigger_slowmo(duration: float, timescale: float):
	Engine.time_scale = timescale

	await get_tree().create_timer(duration * timescale).timeout
	
	var tween = get_tree().create_tween()
	tween.tween_property(Engine, "time_scale", 1.0, 0.3)

#region Backgrounds

func get_available_backgrounds() -> Array:
	return [
		preload("res://assets/backgrounds/base_set/majestic_peaks.png"),
		preload("res://assets/backgrounds/base_set/payramid_desert_sun.png"),
		preload("res://assets/backgrounds/base_set/showdown_in_valley.png"),
		preload("res://assets/backgrounds/base_set/village_market_festival.png"),
		preload("res://assets/backgrounds/base_set/traditional_dojo.png"),
		preload("res://assets/backgrounds/base_set/historic_wall.png"),
		preload("res://assets/backgrounds/base_set/urban_street_fight.png"),
		preload("res://assets/backgrounds/base_set/sunlit_alleyway.png"),
		preload("res://assets/backgrounds/base_set/industrial_factory_interior.png"),
		preload("res://assets/backgrounds/base_set/noche_en_el_santuario.png")
	]


func set_background(texture: Texture):
	if background_image.texture == texture:
		return

	# Optional: Add a shader or animation effect here before switching.
	# For now, simple swap:
	background_image.texture = texture
	
	var new_bg = texture
	
	var mat := background_overlay.material as ShaderMaterial
	mat.set_shader_parameter("transition_progress", 0.0)
	background_overlay.visible = false
	
	# Animate transition
	var tween := get_tree().create_tween()
	tween.tween_property(mat, "shader_parameter/transition_progress", 1.0, 1.2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.finished.connect(func():
		background_image.texture = new_bg
		mat.set_shader_parameter("transition_progress", 0.0)  # Reset
		mat.set_shader_parameter("old_texture", new_bg)  # Reset
		background_overlay.visible = false
	)
	

#endregion
