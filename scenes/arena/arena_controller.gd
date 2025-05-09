extends Node

signal fight_ended(winner: Fighter, loser: Fighter)

var fight_over := false

var fighter_left: Fighter = null
var fighter_right: Fighter = null


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
	
func start_fight():
	fight_over = false

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
	var base = attacker.get_total_stat("strength") * 2
	var reduction = defender.get_total_stat("endurance") * 0.5
	var res =  max(1, base - reduction)
	return res

func show_miss_effect() -> void:
	print("Attack missed!")
	
	
func _on_victory_animation_finished(attacker: BaseFighter) -> void:
	#TODO display win screen and so on
	#show_win_screen()
	pass
	
func _on_attack_hit_window(attacker: Fighter):
	var defender = fighter_right if attacker == fighter_left else fighter_left

	if does_attack_hit(attacker, defender):
		var damage = calculate_damage(attacker, defender)
		defender.apply_damage(damage)
		
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
