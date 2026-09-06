extends Button
class_name AnimatedButton

@export_subgroup("Button SFX")
@export var hover_sound_effect: AudioStream
@export var press_sound_effect: AudioStream

@export_subgroup("Scale Multiplier")
@export_range(1.0, 10.0) var hovering_scale_multiplier: float = 1.25
@export_range(1.0, 10.0) var pressing_scale_multiplier: float = 1.1

@export_subgroup("Tween Speed")
@export_range(0.0, 10.0) var hover_tween_speed: float = 0.25
@export_range(0.0, 10.0) var press_tween_speed: float = 0.1

func _ready() -> void:
	pivot_offset = size / 2
	
	mouse_entered.connect(_is_hovering.bind(self, true))
	mouse_exited.connect(_is_hovering.bind(self, false))
	
	button_up.connect(_is_pressing.bind(self, false))
	button_down.connect(_is_pressing.bind(self, true))

func _is_hovering(button: Button, is_hovering: bool):
	var tween = create_tween()
	if is_hovering:
		tween.tween_property(button, "scale", Vector2.ONE * hovering_scale_multiplier, 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(button, "scale", Vector2.ONE, 0.25)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

func _is_pressing(button: Button, is_down: bool):
	var tween = create_tween()
	if is_down:
		tween.tween_property(button, "scale", Vector2.ONE * pressing_scale_multiplier, 0.1)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(button, "scale", Vector2.ONE * hovering_scale_multiplier, 0.1)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
