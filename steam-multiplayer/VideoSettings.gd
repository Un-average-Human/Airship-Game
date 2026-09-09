extends Control

@export var option_button_array: Array[OptionButton]

@export var window_mode_option: OptionButton
@export var resolution_option: OptionButton
@export var max_framerate_option: OptionButton
@export var vsync_option: OptionButton



var window_modes: Dictionary[String, DisplayServer.WindowMode] = {
	"windowed": DisplayServer.WINDOW_MODE_WINDOWED,
	"windowed_fullscreen": DisplayServer.WINDOW_MODE_FULLSCREEN,
	"fullscreen": DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN
}
var vsync_modes: Dictionary[String, DisplayServer.VSyncMode] = {
	"disabled": DisplayServer.VSYNC_DISABLED,
	"enabled": DisplayServer.VSYNC_ENABLED,
	"adaptive": DisplayServer.VSYNC_ADAPTIVE
}
var max_framerates: Array[int] = [
	30,
	60
]

func _ready() -> void:
	#adding the options to the buttons
	for window_mode: String in window_modes.keys():
		window_mode_option.add_item(window_mode.capitalize())
	
	for vsync_mode: String in vsync_modes.keys():
		vsync_option.add_item(vsync_mode.capitalize())
	
	
	
	#connect buttons to the function
	for option_button in option_button_array:
		option_button.item_selected.connect(_option_buttons.bind(option_button))

func _option_buttons(index: int, button: OptionButton):
	var mode = button.get_item_text(index).to_snake_case()
	match button:
		window_mode_option:
			DisplayServer.window_set_mode(window_modes[mode])
			print(DisplayServer.window_get_mode())
		resolution_option:
			pass
		max_framerate_option:
			pass
		vsync_option:
			DisplayServer.window_set_vsync_mode(vsync_modes[mode])
			print(DisplayServer.window_get_vsync_mode())
