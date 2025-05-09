class_name BaseFighter
extends Node

const FighterClasses = preload("res://data/enums/fighter/fighter_classes.gd")
const FighterPersonality = preload("res://data/enums/fighter/fighter_personality.gd")
const AttackResult = preload("res://data/enums/fighter/attack_result.gd")

const BASE_ATTACK_COOLDOWN := 3.0
signal health_changed
signal stamina_changed
signal special_meter_changed
signal attack_hit_window(fighter: BaseFighter)
signal victory_animation_finished(fighter: BaseFighter)

# Core Stats
@export var fighter_name: String
@export var style: int = FighterClasses.FighterStyle.BALANCED
@export var level: int = 1
@export var experience: int = 0

@export var base_stats: FighterStats = FighterStats.new()
@export var traits: Array[FighterTrait] = []
@export var personality: int = FighterPersonality.Personality.NEUTRAL

@export var attack_cooldown := 0.0
@export var attack_range: float = 50.0  # in pixels
@export var move_speed: float = 50.0    # movement per second

# Context
@export var behavior: FighterBehaviorContext

# Battle status
var health: int : set = set_health
var stamina: int : set = set_stamina
var special_meter: int : set = set_special_meter
var morale: float = 1.0
var fatigue: float = 0.0
var injured: bool = false

var context: FighterContext

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals := FighterVisual.new()
@onready var mover := FighterMover.new()
@onready var fsm: Fsm = $Fsm

# Setters that emit signals
func set_health(value: int) -> void:
	var clamped = clamp(value, 0, max_health())
	if clamped != health:
		health = clamped
		health_changed.emit()

func set_stamina(value: int) -> void:
	var clamped = clamp(value, 0, max_stamina())
	if clamped != stamina:
		stamina = clamped
		stamina_changed.emit()

func set_special_meter(value: int) -> void:
	var clamped = clamp(value, 0, max_special())
	if clamped != special_meter:
		special_meter = clamped
		special_meter_changed.emit()
		
func _process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta
	
	context.update()
		
func _ready():
	health = max_health()
	stamina = max_stamina()
	special_meter = 0
	
	add_child(visuals)
	visuals.init($Sprite2D, $AnimationPlayer)
	
	add_child(mover)
	mover.init(
		move_speed,
		func(): return self.position,
		func(p): self.position = p
		)
		
	
	self.behavior = FighterBehaviorContext.new()
	
	self.context = FighterContext.new()
	self.context.self_fighter = self
	
	fsm.fighter = self
	fsm.init()
	
func max_health() -> int:
	var total = get_total_stats().endurance * 10
	return total
	
func max_stamina() -> int:
	var total = get_total_stats().agility * 5
	return total

func max_special() -> int:
	var total = get_total_stats().technique * 10
	return total

func get_total_stats() -> FighterStats:
	var total := base_stats
	for tr in traits:
		if tr:
			total = total.add(tr.stat_modifiers)
	return total

func get_total_stat(stat_name: String) -> int:
	var stats = get_total_stats()
	match stat_name:
		"strength":
			return stats.strength
		"agility":
			return stats.agility
		"endurance":
			return stats.endurance
		"technique":
			return stats.technique
		_:
			push_warning("Unknown stat name: %s" % stat_name)
			return 0


func get_attack_speed() -> float:
	# Faster with more agility
	var agility = get_total_stat("agility")
	var res = BASE_ATTACK_COOLDOWN / (1.0 + agility * 0.1)
	return res
	
func check_attack_possible(on_hit: bool) -> int:
	if attack_cooldown > 0.0:
		return AttackResult.AttackCheckResult.COOLDOWN_ACTIVE
	if stamina < get_stamina_cost(on_hit):
		return AttackResult.AttackCheckResult.NOT_ENOUGH_STAMINA
	return AttackResult.AttackCheckResult.SUCCESS

func can_attack(on_hit: bool) -> bool:
	var res = check_attack_possible(on_hit) == AttackResult.AttackCheckResult.SUCCESS
	return res

	
func reset_attack_cooldown():
	attack_cooldown = get_attack_speed()

func apply_damage(amount: int):
	health -= amount
	if health < 0:
		health = 0
	health_changed.emit()
	#visuals.flash_hit()
	on_hit(amount)
	
func use_stamina(on_hit: bool):
	var cost = get_stamina_cost(on_hit)
	stamina = max(0, stamina - cost)
	stamina_changed.emit()
	
func get_stamina_cost(on_hit: bool) -> int:
	return 10 if on_hit else 5
	
func is_in_range(target: Node) -> bool:
	var distance = self.position.distance_to(target.position)
	var res = distance <= attack_range
	return res
	
func move_away_from(target: Node, delta: float) -> void:
	#var direction = (self.position - target.position).normalized()
	#var desired_distance = 200  # pixels away
	#if self.position.distance_to(target.position) < desired_distance:
		#self.position += direction * (move_speed / 2) * delta
	mover.move_away(target.position, delta)


func move_toward_target(target: Node, delta: float) -> void:
	#var direction = (target.position - self.position).normalized()
	#self.position += direction * move_speed * delta
	mover.move_toward(target.position, delta)
	
func flip_sprite(is_flip: bool):
	if sprite_2d:
		sprite_2d.flip_h = is_flip
		
func get_trait_behavior_modifier() -> float:
	# Placeholder for now
	return 0.0
	
func play_attack_animation():
	visuals.play_attack()
		
func is_playing_attack_animation() -> bool:
	return visuals.is_playing_attack()
	
func emit_attack_hit_window():
	attack_hit_window.emit(self)

func on_hit(amount: int = 0):
	fsm.switch_state(FsmState.StateId.HIT)

func on_death():
	fsm.switch_state(FsmState.StateId.DEAD)
