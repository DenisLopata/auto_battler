extends Node2D

@export var camera: Camera2D
@export var zoom_lerp_speed := 5.0
@export var position_lerp_speed := 5.0

@export var world_bounds := Rect2(Vector2.ZERO, Vector2(1024, 1024))
#@export var default_position := Vector2(512, 512)
#@export var default_position := Vector2(320, -120)
@export var default_position := Vector2(320, 0)
#@export var vertical_limits := Vector2(200, 824) # Min Y, Max Y
@export var vertical_limits := Vector2(0, 824) # Min Y, Max Y

var target_position: Vector2
var target_zoom: Vector2 = Vector2.ONE

var tracked_a: Node2D
var tracked_b: Node2D

# Punch zoom
var base_zoom := Vector2.ONE
var punch_target_zoom := Vector2.ONE
var punch_timer := 0.0
var punch_duration := 0.25
#var punch_cooldown := 0.1
var punch_cooldown := 10
var last_punch_time := -10.0
var max_punch_amount := 0.8


@onready var dynamic_camera: Camera2D = $DynamicCamera

func _ready():
	camera = dynamic_camera
	

func _process(delta):
	#returnTODO enable camera
	
	if tracked_a and tracked_b:
		focus_on(tracked_a, tracked_b)
	else:
		target_position = default_position
		target_zoom = base_zoom

	# Camera punch easing
	if punch_timer > 0.0:
		punch_timer -= delta
		var t = 1.0 - (punch_timer / punch_duration)
		var eased_t = 1.0 - pow(1.0 - t, 3) # Ease-out cubic

		target_zoom = punch_target_zoom.lerp(base_zoom, eased_t)
	else:
		target_zoom = base_zoom

	# Smooth follow and zoom
	target_position.x = clamp(target_position.x, world_bounds.position.x, world_bounds.end.x)
	target_position.y = clamp(target_position.y, vertical_limits.x, vertical_limits.y)
	global_position = global_position.lerp(target_position, delta * position_lerp_speed)
	camera.zoom = camera.zoom.lerp(target_zoom, delta * zoom_lerp_speed)


func focus_on(fighter_a: Node2D, fighter_b: Node2D):
	var center = (fighter_a.global_position + fighter_b.global_position) / 2.0
	var distance = fighter_a.global_position.distance_to(fighter_b.global_position)
	
	target_position = center
	target_zoom = Vector2.ONE * clamp(400.0 / distance, 0.6, 1.2)


func _on_fighters_ready(f1: Node2D, f2: Node2D):
	tracked_a = f1
	tracked_b = f2

func punch_zoom_effect(strength := 1.0):
	var now = Time.get_ticks_msec() / 1000.0
	if now - last_punch_time < punch_cooldown:
		return # Skip if too soon

	last_punch_time = now
	punch_timer = punch_duration

	var punch_amount = clamp(strength, 0.0, 1.0) * max_punch_amount
	#	zoom out
	#punch_target_zoom = base_zoom * (1.0 - punch_amount)
	#	zoom in
	punch_target_zoom = base_zoom * (1.0 + punch_amount)
