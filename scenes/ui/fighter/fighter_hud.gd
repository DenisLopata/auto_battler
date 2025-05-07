class_name FighterHUD
extends Control

@export var fighters: Array[Fighter] = []

@export var fighter_bar_group_scene: PackedScene
@onready var container: VBoxContainer = %VBoxContainer

var fighter_ui = {}

func _ready():
	_initialize_ui()

func _initialize_ui():
	for child in container.get_children():
		child.queue_free()

	fighter_ui.clear()

	for fighter in fighters:
		var group = fighter_bar_group_scene.instantiate()
		container.add_child(group)

		group.get_node("NameLabel").text = fighter.fighter_name
		_update_bars(fighter, group)

		fighter.health_changed.connect(func(): _update_bars(fighter, group))
		fighter.stamina_changed.connect(func(): _update_bars(fighter, group))
		fighter.special_meter_changed.connect(func(): _update_bars(fighter, group))

		fighter_ui[fighter] = group

func _update_bars(fighter: Fighter, group: VBoxContainer):
	group.get_node("HealthBar").value = fighter.health
	group.get_node("HealthBar").max_value = fighter.max_health()

	group.get_node("StaminaBar").value = fighter.stamina
	group.get_node("StaminaBar").max_value = fighter.max_stamina()

	group.get_node("SpecialMeter").value = fighter.special_meter
	group.get_node("SpecialMeter").max_value = fighter.max_special()



#class_name FighterHUD
#extends Control
#
#@export var fighter: Fighter
#
#@onready var name_label: Label = %NameLabel
#@onready var health_bar: ProgressBar = %HealthBar
#@onready var stamina_bar: ProgressBar = %StaminaBar
#@onready var special_meter: ProgressBar = %SpecialMeter
#
#func _ready():
	#if fighter:
		#_initialize_ui()
		#_connect_fighter_signals()
#
#func _initialize_ui():
	#name_label.text = fighter.fighter_name
	#_update_bars()
#
#func _connect_fighter_signals():
	#fighter.health_changed.connect(_update_bars)
	#fighter.stamina_changed.connect(_update_bars)
	#fighter.special_meter_changed.connect(_update_bars)
#
#func _update_bars():
	#health_bar.value = fighter.health
	#var max_health = fighter.max_health()
	#health_bar.max_value = max_health
#
	#stamina_bar.value = fighter.stamina
	#var max_stamina = fighter.max_stamina()
	#stamina_bar.max_value = max_stamina
#
	#special_meter.value = fighter.special_meter
	#var max_special = fighter.max_special()
	#special_meter.max_value = max_special
