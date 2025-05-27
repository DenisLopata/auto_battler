# res://scenes/ui/betting_panel/betting_panel.gd
class_name BettingPanel
extends Control

signal bet_made(fighter: Fighter)

var left_fighter: Fighter
var right_fighter: Fighter
var selected_fighter: Fighter = null

@onready var button_left: Button = $VBoxContainer/FighterButtons/FighterButtonLeft
@onready var button_right: Button = $VBoxContainer/FighterButtons/FighterButtonRight
@onready var confirm_button: Button = $VBoxContainer/ConfirmButton
@onready var score_label: Label = $VBoxContainer/ScoreLabel

func _ready():
	button_left.pressed.connect(_on_left_pressed)
	button_right.pressed.connect(_on_right_pressed)
	confirm_button.pressed.connect(_on_confirm_pressed)
	confirm_button.disabled = true
	score_label.text = ""
	
func update_score(text: String) -> void:
	score_label.text = "Score: " + text

func set_fighters(left: Fighter, right: Fighter):
	left_fighter = left
	right_fighter = right
	button_left.text = left.fighter_name
	button_right.text = right.fighter_name
	confirm_button.disabled = true
	selected_fighter = null
	highlight_selection(-1)

func _on_left_pressed():
	selected_fighter = left_fighter
	highlight_selection(0)
	confirm_button.disabled = false

func _on_right_pressed():
	selected_fighter = right_fighter
	highlight_selection(1)
	confirm_button.disabled = false

func _on_confirm_pressed():
	if selected_fighter:
		bet_made.emit(selected_fighter)
		confirm_button.disabled = true

func highlight_selection(index: int):
	var normal_color = Color.WHITE
	var selected_color = Color.GREEN
	button_left.add_theme_color_override("font_color", normal_color)
	button_left.add_theme_color_override("font_focus_color", normal_color)
	button_right.add_theme_color_override("font_color", normal_color)
	button_right.add_theme_color_override("font_focus_color", normal_color)
	
	if index == 0:
		button_left.add_theme_color_override("font_color", selected_color)
		button_left.add_theme_color_override("font_focus_color", selected_color)
		#button_left.add_theme_color_override("font_hover_color", selected_color)
		#button_left.add_theme_color_override("font_hover_pressed_color", selected_color)
	elif index == 1:
		button_right.add_theme_color_override("font_color", selected_color)
		button_right.add_theme_color_override("font_focus_color", selected_color)
		#button_right.add_theme_color_override("font_hover_color", selected_color)
		#button_right.add_theme_color_override("font_hover_pressed_color", selected_color)
