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

# Battle status
var health: int : set = set_health
var stamina: int : set = set_stamina
var special_meter: int : set = set_special_meter
var morale: float = 1.0
var fatigue: float = 0.0
var injured: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer

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
		
func _ready():
	health = max_health()
	stamina = max_stamina()
	special_meter = 0

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
	show_hit_flash()
	
func show_hit_flash():
	sprite_2d.modulate = Color(1, 0.2, 0.2)  # red flash
	await get_tree().create_timer(0.1).timeout
	sprite_2d.modulate = Color(1, 1, 1)  # reset to normal

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
	var direction = (self.position - target.position).normalized()
	var desired_distance = 200  # pixels away
	if self.position.distance_to(target.position) < desired_distance:
		self.position += direction * (move_speed / 2) * delta


func move_toward_target(target: Node, delta: float) -> void:
	var direction = (target.position - self.position).normalized()
	self.position += direction * move_speed * delta
	
func flip_sprite(is_flip: bool):
	if sprite_2d:
		sprite_2d.flip_h = is_flip
		
func get_trait_behavior_modifier() -> float:
	# Placeholder for now
	return 0.0
	
func play_attack_animation():
	if $AnimationPlayer.has_animation("basic_punch"):
		$AnimationPlayer.play("basic_punch")
		
func is_playing_attack_animation() -> bool:
	return $AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == "basic_punch"

func emit_attack_hit_window():
	attack_hit_window.emit(self)
