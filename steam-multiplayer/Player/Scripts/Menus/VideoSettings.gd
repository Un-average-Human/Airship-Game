extends Control

@export var option_button_array: Array[OptionButton]

@export var window_mode_option: OptionButton
@export var resolution_option: OptionButton
@export var vsync_option: OptionButton

@export var framerate_line_edit: LineEdit
@export var framerate_slider: HSlider
var last_framerate: int = -1



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

func _ready() -> void:
	#adding the options to the buttons
	for window_mode: String in window_modes.keys():
		window_mode_option.add_item(window_mode.capitalize())
	
	for vsync_mode: String in vsync_modes.keys():
		vsync_option.add_item(vsync_mode.capitalize())
	
	_load_settings()
	
	#connect buttons to the function
	for option_button in option_button_array:
		option_button.item_selected.connect(_option_buttons.bind(option_button))
	framerate_slider.value_changed.connect(_max_framerate_slider)
	
	framerate_line_edit.text_changed.connect(_framerate_text_changed)
	framerate_line_edit.text_submitted.connect(_max_framerate_text)


func _load_settings() -> void:
	var video_settings = ConfigFileManager.load_video_settings()
	
	if video_settings.has("window_mode"):
		var mode = video_settings["window_mode"]
		var keys = window_modes.keys()
		var index = keys.find(mode)
		window_mode_option.selected = index
		DisplayServer.window_set_mode(window_modes[mode])

	if video_settings.has("vsync_mode"):
		var vsync = video_settings["vsync_mode"]
		var keys = vsync_modes.keys()
		var index = keys.find(vsync)
		if index != -1:
			vsync_option.selected = index
			DisplayServer.window_set_vsync_mode(vsync_modes[vsync])

	if video_settings.has("max_framerate"):
		var max_framerate = int(video_settings["max_framerate"])
		framerate_slider.value = max_framerate
		_update_max_framerate(max_framerate)


func _option_buttons(index: int, button: OptionButton) -> void:
	var mode = button.get_item_text(index).to_snake_case()
	match button:
		window_mode_option:
			DisplayServer.window_set_mode(window_modes[mode])
			ConfigFileManager.save_video_settings("window_mode", mode)
		resolution_option:
			pass
		vsync_option:
			DisplayServer.window_set_vsync_mode(vsync_modes[mode])
			ConfigFileManager.save_video_settings("vsync_mode", mode)

func _max_framerate_slider(new_value: float) -> void:
	if int(new_value) == last_framerate:
		return
	
	_update_max_framerate(int(new_value))
	ConfigFileManager.save_video_settings("max_framerate", int(new_value))

func _max_framerate_text(new_text: String) -> void:
	var raw_number : int = new_text.trim_suffix("FPS").to_int()
	
	if new_text.to_lower().strip_edges() == "unlimited" or raw_number > 600 or raw_number <= 0:
		raw_number = 601
		
	if raw_number < 30 and raw_number != 0:
		raw_number = 30
		
	framerate_slider.value = raw_number
	_update_max_framerate(raw_number)
	ConfigFileManager.save_video_settings("max_framerate", raw_number)

func _update_max_framerate(value: int) -> void:
	last_framerate = value
	
	if value > 600 or value <= 0:
		Engine.max_fps = 0
		framerate_line_edit.text = "Unlimited"
	else:
		Engine.max_fps = value
		framerate_line_edit.text = str(value) + " FPS"

func _framerate_text_changed(new_text: String) -> void:
	var filtered_text : String = ""
	for character in new_text:
		if character.is_valid_int():
			filtered_text += character
			
	if framerate_line_edit.text != filtered_text:
		var caret_pos = framerate_line_edit.caret_column
		framerate_line_edit.text = filtered_text
		framerate_line_edit.caret_column = caret_pos
