@icon("res://addons/at-icons/node3d/wheel.svg")
extends Node3D
class_name Valve

@export var valve_handle: Marker3D
@export var valve_mesh: Node3D

var current_camera: Camera3D
var is_grabbed: bool = false
var player: CharacterBody3D

# SOMA style tracking variables
var virtual_mouse_pos: Vector2 = Vector2.ZERO
@export var crank_sensitivity: float = 0.000015

func execute(player_interacting: CharacterBody3D) -> void:
	player = player_interacting
	
	player.is_camera_locked = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	is_grabbed = true
	
	#changes the cur-SON position (aka offsets it, idk why i didnt js say that) so it wont get screwed up
	virtual_mouse_pos = Vector2(100, 0)

func _unhandled_input(event: InputEvent) -> void:
	if not is_grabbed:
		return
		
	#tracks the movement fromm da hand
	if event is InputEventMouseMotion:
		#update the fake cursor with the real movement
		virtual_mouse_pos += event.relative
		
		#instead of using atan2, this lets me make the turning smoother without any snapping as well as only
		#accepting mouse movement that goes around the valve, not straight down or across
		var change = (virtual_mouse_pos.x * event.relative.y) - (virtual_mouse_pos.y * event.relative.x)
		
		#clamping the fake cursor so it wont mess with the sensitivity
		if virtual_mouse_pos.length() > 150.0:
			virtual_mouse_pos = virtual_mouse_pos.normalized() * 150.0
		elif virtual_mouse_pos.length() < 50.0:
			virtual_mouse_pos = virtual_mouse_pos.normalized() * 50.0
			
		valve_mesh.rotate_object_local(Vector3.RIGHT, change * crank_sensitivity)
	
	if Input.is_action_just_released("interact"):
		is_grabbed = false
		player.is_camera_locked = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
