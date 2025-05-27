# res://characters/base_fighter.gd
class_name BaseFighter
extends Node

const FighterClasses = preload("res://data/enums/fighter/fighter_classes.gd")
const FighterPersonality = preload("res://data/enums/fighter/fighter_personality.gd")
const AttackResult = preload("res://data/enums/fighter/attack_result.gd")
const MoveLibrary = preload("res://data/moves/move_library.gd")

const BASE_ATTACK_COOLDOWN := 3.0
signal health_changed
signal stamina_changed
signal special_meter_changed
signal attack_hit_window(fighter: BaseFighter, move: MoveData)
signal victory_animation_finished(fighter: BaseFighter)

# Core Stats
@export var fighter_name: String
@export var style: int = FighterClasses.FighterStyle.BALANCED
@export var level: int = 1
@export var experience: int = 0
@export var special_meter_max: float = 100.0

@export var base_stats: FighterStats = FighterStats.new()
@export var traits: Array[FighterTrait] = []
@export var personality: int = FighterPersonality.Personality.NEUTRAL

@export var attack_cooldown := 0.0
@export var attack_range: float = 50.0  # in pixels
@export var move_speed: float = 50.0    # movement per second

# Context
@export var behavior: FighterBehaviorContext

# Moves
@export var moves: Array[MoveData] = []
@export var default_move: MoveData

# Battle status
var health: int : set = set_health
var stamina: float : set = set_stamina
	
var special_meter: float : set = set_special_meter
var morale: float = 1.0
var fatigue: float = 0.0
var injured: bool = false


var context: FighterContext

var is_blocking: bool = false

var fight_is_active: bool = false

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var visuals := FighterVisual.new()
@onready var mover := FighterMover.new()
@onready var fsm: Fsm = $Fsm
@onready var move_controller: MoveController = $MoveController

#region Setters

# Setters that emit signals
func set_health(value: int) -> void:
	var clamped = clamp(value, 0, max_health())
	if clamped != health:
		health = clamped
		health_changed.emit()

func set_stamina(value: float) -> void:
	var clamped = clamp(value, 0, max_stamina())
	if clamped != stamina:
		stamina = clamped
		stamina_changed.emit()

		
func set_special_meter(value: float) -> void:
	var clamped = clamp(value, 0, max_special())
	if clamped != special_meter:
		special_meter = clamped
		special_meter_changed.emit()

#endregion

#region Defaults

func _process(delta):
	if attack_cooldown > 0:
		attack_cooldown -= delta
		
	
	if not fight_is_active:
		return
		
	context.update(self)
	move_controller.update(delta)
	
	var add_stm = get_stamina_regen_rate() * delta
	if add_stm > 0:
		stamina += add_stm
	

		
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
	
	var ml = MoveLibrary.new()
	var move_data = ml.create_basic_punch()
	moves.append(move_data)
	
	var special = ml.create_basic_special()
	moves.append(special)
	
	self.default_move = move_data
	
	#move_controller.attack_window_started.connect(_on_attack_window_started)
	#move_controller.move_finished.connect(_on_move_finished)

#endregion

#region Signals

#func _on_attack_window_started(move: MoveData):
	##emit_attack_hit_window(move)
	#emit_attack_hit_window()

#func _on_move_finished(move: MoveData):
	#print("Move finished: ", move.name)


#endregion

#region Helpers

func max_health() -> int:
	var total = get_total_stats().endurance * 10
	return total
	
func max_stamina() -> float:
	var total = get_total_stats().agility * 5
	return total

func max_special() -> float:
	#var total = get_total_stats().technique * 10
	var total = special_meter_max
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

func apply_damage(amount: int) -> bool:
	var was_blocked: bool = false
	
	if is_blocking:
		amount *= 0.3
		was_blocked = true
		
	health -= amount
	if health < 0:
		health = 0
	health_changed.emit()
	#visuals.flash_hit()
	on_hit(amount)
	return was_blocked
	
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
	

func get_stamina_regen_rate() -> float:
	var base_rate := 0.8  # stamina per second
	
	
	# Adjust based on state
	match fsm.current_state_id:
		FsmState.StateId.RETREAT:
			base_rate *= 1.5
		FsmState.StateId.IDLE:
			base_rate *= 1.2
		FsmState.StateId.BLOCK:
			base_rate *= 0.8
		FsmState.StateId.ATTACK:
			base_rate = 0.0

	# Apply trait modifiers (if implemented)
	#base_rate += get_trait_stamina_regen_bonus()

	return base_rate

func add_special(amount: float = 1) -> void:
	
	var tech_multiplier := get_total_stats().technique / 10.0  # or some balanced factor
	var fill_rate := 1.0 + tech_multiplier  # So technique 10 = 2.0x, technique 5 = 1.5x
	
	special_meter += amount * fill_rate
	special_meter = clamp(special_meter, 0, max_special())
	special_meter_changed.emit()

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
	var selected_move = move_controller.current_move
	attack_hit_window.emit(self, selected_move)
	
#func emit_attack_hit_window(move: MoveData):
	#attack_hit_window.emit(self, move)

func on_hit(amount: int = 0):
	fsm.switch_state(FsmState.StateId.HIT)

func on_death():
	fsm.switch_state(FsmState.StateId.DEAD)

func select_best_move(context: FighterContext) -> MoveData:
	var best_move: MoveData = null
	var distance := context.distance_to_target
	var stamina := context.self_fighter.stamina

	for move in moves:
		if not move: continue
		if "special" in move.tags: continue # ❌ Skip special moves
		if move.stamina_cost > stamina:
			continue

		# Prioritize close-range if we're close, or ranged if far
		if distance < 60.0 and move.knockback < 0.5:
			best_move = move
			break
		elif distance >= 60.0 and move.knockback >= 0.5:
			best_move = move
			break
	
	# Fallback to any usable move if nothing matched above
	if not best_move:
		for move in moves:
			if move and move.stamina_cost <= stamina \
			 and "special" not in move.tags:
				best_move = move
				break

	# If absolutely no usable move, return null (can be handled as idle or block)
	return best_move

func get_move_by_name(name: String) -> MoveData:
	for move in moves:
		if move.name == name:
			return move
	return null

#endregion
