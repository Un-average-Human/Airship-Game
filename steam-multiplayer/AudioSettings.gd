extends Control

#MICROPHONE
@export_subgroup("Microphone")
@export var microphone_button: OptionButton
@export var input_mode_button: OptionButton
@export var option_button_array: Array[OptionButton]

enum InputModes {
	VOICE_ACTIVATION,
	PUSH_TO_TALK,
	TOGGLE_TO_TALK
}

#SLIDERS
@export var slider_array: Array[HSlider]

func _ready() -> void:
	for slider: HSlider in slider_array:
		slider.drag_ended.connect(_manage_volume.bind(slider))
	
	#MICROPHONE
	for input_device in AudioServer.get_input_device_list():
		microphone_button.add_item(str(input_device))
	
	for input_mode: String in InputModes.keys():
		var input_mode_name = input_mode.capitalize()
		input_mode_button.add_item(input_mode_name, InputModes[input_mode])
	
	for option_button: OptionButton in option_button_array:
		option_button.item_selected.connect(_manage_microphone.bind(option_button))
	
	_load_settings()

func _load_settings():
	var audio_settings: Dictionary = ConfigFileManager.load_audio_settings()
	for slider: HSlider in slider_array:
		var slider_name = slider.name.to_snake_case().trim_suffix("_slider")
		slider.value = min(audio_settings[slider_name], 1.0) * 100
	
	for option_button in option_button_array:
		if audio_settings.has(option_button.name.to_snake_case()):
			var button_name = str(audio_settings[option_button.name.to_snake_case()])
			for i in range(option_button.get_item_count()):
				if option_button.get_item_text(i) == button_name:
					option_button.select(i)

func _manage_volume(value_changed: bool, slider: HSlider):
	ConfigFileManager.save_audio_settings(slider.name.to_snake_case().trim_suffix("_slider"), slider.value / 100)

func _manage_microphone(index: int, button: OptionButton):
	var value = button.get_item_text(index)
	match button:
		microphone_button:
			ConfigFileManager.save_audio_settings("microphone", value)
		input_mode_button:
			ConfigFileManager.save_audio_settings("input_mode", value)
