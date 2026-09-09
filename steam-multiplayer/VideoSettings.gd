extends Control

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
	for window_mode: String in window_modes.keys():
		window_mode_option.add_item(window_mode.capitalize())
	
	for vsync_mode: String in vsync_modes.keys():
		vsync_option.add_item(vsync_mode.capitalize())
