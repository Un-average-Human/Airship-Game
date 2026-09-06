extends Control

@export var input_button_scene: PackedScene
@export var action_list: VBoxContainer

var is_remapping: bool = false
var action_to_remap = null
var remapping_button: Button = null

@export var input_actions: Dictionary[String, String] = {
	"forward" : "Forward",
	"backward" : "Backward",
	"left" : "Left",
	"right" : "Right",
	"jump" : "Jump"
}

func _ready() -> void:
	_create_action_list()

func _create_action_list():
	InputMap.load_from_project_settings()
	for item in action_list.get_children():
		item.queue_free()
	
	for action in input_actions:
		var button: Button = input_button_scene.instantiate()
		var action_label: Label = button.find_child("ActionLabel")
		var input_label: Label = button.find_child("InputLabel")
		
		action_label.text = input_actions[action]
		
		var events: Array = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().split(" ")[0]
		else:
			input_label.text = "No Keybind"
		
		action_list.add_child(button)
