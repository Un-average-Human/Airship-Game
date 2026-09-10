extends Node

#ENUMS
enum {
	VOICE_ACTIVATION,
	PUSH_TO_TALK,
	TOGGLE_TO_TALK
}

var config := ConfigFile.new()
const SETTINGS_FILE_PATH: String = "user://settings.ini"

func _ready() -> void:
	if not FileAccess.file_exists(SETTINGS_FILE_PATH):
		#GENERAL SETTINGS
		config.set_value("general", "fov", 70)
		
		#CONTROLS SETTINGS
		config.set_value("controls", "mouse_sens", 0.005)
		config.set_value("controls", "invert_x", false)
		config.set_value("controls", "invert_y", false)
		
		#KEYBIND SETTINGS
		config.set_value("keybinding", "forward", "W")
		config.set_value("keybinding", "backward", "S")
		config.set_value("keybinding", "left", "A")
		config.set_value("keybinding", "right", "D")
		config.set_value("keybinding", "jump", "Space")
		
		#VIDEO SETTINGS
		config.set_value("video", "window_mode", "windowed_fullscreen")
		config.set_value("video", "max_framerate", 0)
		config.set_value("video", "vsync_mode", "disabled")
		
		#AUDIO SETTINGS
		config.set_value("audio", "microphone", "")
		config.set_value("audio", "input_mode", 0)
		config.set_value("audio", "master_volume", 1.0)
		config.set_value("audio", "music_volume", 1.0)
		config.set_value("audio", "sfx_volume", 1.0)
		config.set_value("audio", "voice_volume", 1.0)
		
		config.save(SETTINGS_FILE_PATH)
	else:
		config.load(SETTINGS_FILE_PATH)
	apply_keybinds()



##SAVE AND LOAD

#VIDEO SETTINGS
func save_video_settings(key: String, value: Variant):
	config.set_value("video", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_video_settings() -> Dictionary:
	var video_settings: Dictionary = {}
	for key in config.get_section_keys("video"):
		video_settings[key] = config.get_value("video", key)
	return video_settings


#AUDIO SETTINGS
func save_audio_settings(key: String, value: Variant):
	config.set_value("audio", key, value)
	config.save(SETTINGS_FILE_PATH)

func load_audio_settings() -> Dictionary:
	var audio_settings: Dictionary = {}
	for key in config.get_section_keys("audio"):
		audio_settings[key] = config.get_value("audio", key)
	return audio_settings


#KEYBINDING
func save_keybinds(action: StringName, event: InputEvent):
	var event_str: String
	if event is InputEventKey:
		event_str = OS.get_keycode_string(event.physical_keycode)
	elif event is InputEventMouseButton:
		event_str = "mouse_" + str(event.button_index)
	
	config.set_value("keybinding", action, event_str)
	config.save(SETTINGS_FILE_PATH)

func load_keybinds() -> Dictionary:
	var keybinds: Dictionary = {}
	var keys = config.get_section_keys("keybinding")
	for key in keys:
		var input_event: InputEvent
		var event_str = config.get_value("keybinding", key)
		
		if event_str.contains("mouse_"):
			input_event = InputEventMouseButton.new()
			input_event.button_index = int(event_str.split("_")[1])
		else:
			input_event = InputEventKey.new()
			input_event.keycode = OS.find_keycode_from_string(event_str)
		
		keybinds[key] = input_event
	return keybinds

func apply_keybinds() -> void:
	var keybinds: Dictionary = load_keybinds()
	
	for action in keybinds:
		if InputMap.has_action(action):
			InputMap.action_erase_events(action)
			InputMap.action_add_event(action, keybinds[action])
