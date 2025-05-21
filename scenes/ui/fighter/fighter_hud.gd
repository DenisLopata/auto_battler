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

	var h = fighter.health
	var mh = fighter.max_health()
	group.get_node("HealthBar").allow_greater = true
	group.get_node("HealthBar").value = h
	group.get_node("HealthBar").max_value = mh
	
	group.get_node("StaminaBar").allow_greater = true
	group.get_node("StaminaBar").value = fighter.stamina
	group.get_node("StaminaBar").max_value = fighter.max_stamina()

	group.get_node("SpecialMeter").allow_greater = true
	group.get_node("SpecialMeter").value = fighter.special_meter
	group.get_node("SpecialMeter").max_value = fighter.max_special()
	
	if OS.is_debug_build():
		_update_debug_stats(fighter, group)


func _update_debug_stats(fighter: Fighter, group: VBoxContainer):
		var label := group.get_node("DebugStatsLabel") as RichTextLabel
		if not label:
			return
		
		label.text = "[b]Stats:[/b]\n"
		label.text += "STR: %d\n" % fighter.base_stats.strength
		label.text += "AGI: %d\n" % fighter.base_stats.agility
		label.text += "END: %d\n" % fighter.base_stats.endurance
		label.text += "TEC: %d\n" % fighter.base_stats.technique
		label.text += "\n"
		label.text += "[b]Health:[/b] %.1f / %.1f\n" % [fighter.health, fighter.max_health()]
		label.text += "[b]Stamina:[/b] %.1f / %.1f\n" % [fighter.stamina, fighter.max_stamina()]
		label.text += "[b]Special:[/b] %.1f / %.1f\n" % [fighter.special_meter, fighter.max_special()]
		
