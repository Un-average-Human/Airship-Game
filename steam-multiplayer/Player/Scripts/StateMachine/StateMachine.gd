extends Node
class_name StateMachine

@export_subgroup("State Machine")
@export var starting_state: PlayerState
@export var state_machine: StateMachine
@export var states: Array[PlayerState] = []

var active_state: PlayerState

@export var player: CharacterBody3D

func _ready() -> void:
	for state in states:
		state.player = player
		state.state_machine = self

func _state_manager():
	pass
