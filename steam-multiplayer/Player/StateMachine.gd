extends Node
class_name StateMachine

@export var starting_state: PlayerState

var active_state: PlayerState
var states: Dictionary[String, Node] = {}

var player

func _ready() -> void:
	player = get_parent()
	
	for child in get_children():
		if child is PlayerState:
			states[child.name.to_lower()] = child
			child.player = player
		
	if starting_state:
		change_state(starting_state.name)

func _physics_process(delta: float) -> void:
	if active_state and active_state.has_method("physics_update"):
		active_state.physics_update(delta)

func change_state(new_state_name: String) -> void:
	var target_state = states.get(new_state_name.to_lower())
	if not target_state or target_state == active_state:
		return
		
	if active_state:
		active_state._exit_state()
		
	active_state = target_state
	active_state._enter_state()
