class_name MoveData
extends Resource

@export var name: String = "Unnamed Move"

# Animation
@export var animation_name: String = ""
@export var animation_fps: int = 30  # Needed for frame timing

# Frame windows
@export var startup_frames: int = 5
@export var active_frames: int = 3
@export var recovery_frames: int = 7

# Combat mechanics
@export var damage: int = 10
@export var stamina_cost: int = 5
@export var knockback: float = 0.0
@export var causes_stagger: bool = true

# Defense interactions
@export var can_be_blocked: bool = true
@export var block_stun_frames: int = 4
@export var can_be_countered: bool = true
@export var counter_window_start: int = 1
@export var counter_window_end: int = 3

# Interrupt
@export var is_interruptible: bool = true
@export var interruptible_start_frame: int = 0
@export var interruptible_end_frame: int = 999

# Special interactions
@export var causes_camera_shake_on_hit: bool = false
@export var causes_camera_slowmo_on_ko: bool = false
@export var slowmo_duration : float = 0.4
@export var slowmo_timescale  : float = 0.3

# Audio-visual
@export var hit_sound: AudioStream
@export var special_effect: PackedScene  # VFX on hit

# Optional metadata
@export var tags: Array[String] = []  # e.g. ["high", "punch", "power"]
