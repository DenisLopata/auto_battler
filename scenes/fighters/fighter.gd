class_name Fighter
extends BaseFighter

@onready var debug_label: RichTextLabel = $DebugLabel
@export var debug_enabled: bool = true

func _process(_delta: float) -> void:
	if OS.is_debug_build():
		update_debug_label()
		debug_label.visible = true
		if self.name.contains("FighterLeft"):
			debug_label.position.y = -75
		if self.name.contains("FighterRight"):
			debug_label.position.y = -100
	else:
		debug_label.visible = false
	
	super._process(_delta)

func _ready() -> void:
	super._ready()

func update_debug_label() -> void:
	
	var fighter_intent: FighterIntent = context.intent
	var state_text: String = fsm.get_current_state_name()
	var intent_text := fighter_intent.type_string()  # Assuming you have a method or property for this
	
	debug_label.text = "State: %s\nIntent: %s" % [state_text, intent_text]
