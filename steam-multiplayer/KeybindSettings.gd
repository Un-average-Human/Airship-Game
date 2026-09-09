extends Control

@export var back_button: Button
@export var reset_button: Button
@export var input_button_scene: PackedScene
@export var action_list: VBoxContainer

var is_remapping: bool = false
var action_to_remap: String = ""
var remapping_button: Button = null

@export var input_actions: Dictionary[String, String] = {
	"forward" : "Forward",
	"backward" : "Backward",
	"left" : "Left",
	"right" : "Right",
	"jump" : "Jump"
}

func _ready() -> void:
	reset_button.pressed.connect(_reset_keybinds)
	back_button.pressed.connect(queue_free)
	
	_load_keybinds_from_settings()
	_create_action_list()

func _load_keybinds_from_settings():
	var keybinds = ConfigFileManager.load_keybinds()
	for action in keybinds.keys():
		InputMap.action_erase_events(action)
		InputMap.action_add_event(action, keybinds[action])

func _create_action_list() -> void:
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button: Button = input_button_scene.instantiate()
		var action_label: Label = button.find_child("ActionLabel")
		var input_label: Label = button.find_child("InputLabel")
		
		action_label.text = input_actions[action]
		
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().split(" ")[0]
		else:
			input_label.text = "No Keybind"
		
		action_list.add_child(button)
		button.pressed.connect(_remap_button_pressed.bind(button, action))

func _remap_button_pressed(button: Button, action: String) -> void:
	if not is_remapping:
		is_remapping = true
		action_to_remap = action
		remapping_button = button
		button.find_child("InputLabel").text = "Press a key to bind"

func _input(event: InputEvent) -> void:
	if is_remapping:
		if event is InputEventKey or event is InputEventMouseButton and event.pressed:
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			ConfigFileManager.save_keybinds(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = ""
			remapping_button = null
			
			accept_event()

func _update_action_list(button: Button, event: InputEvent):
	button.find_child("InputLabel").text = event.as_text().split(" ")[0]

func _reset_keybinds():
	InputMap.load_from_project_settings()
	for action in input_actions:
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.size() > 0:
			ConfigFileManager.save_keybinds(action, events[0])
	_create_action_list()
