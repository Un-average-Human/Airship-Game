@icon("res://addons/at-icons/node3d/wheel.svg")
extends StaticBody3D
class_name Valve

@export var hand_pos: Marker3D
@export var crank_sensitivity: float = 5.0
@export var valve_mesh: Node3D

@export var is_vent: bool = false
@export var min_rotation: float = -720
@export var max_rotation: float = 720
@export var starting_rotation: float

var value: float
var sensitivity_multiplier: float = 0.00001

var is_grabbed: bool = false
var player: CharacterBody3D
var virtual_mouse_pos: Vector2 = Vector2.ZERO

func _ready() -> void:
	valve_mesh.rotation.z = deg_to_rad(starting_rotation)
	if is_vent:
		value = 1.0

func execute(player_interacting: CharacterBody3D) -> void:
	if player != null:
		return
	_multiplayer_manager.rpc(true, player_interacting.get_path())

@rpc("any_peer", "call_local", "reliable")
func _multiplayer_manager(grabbed: bool, player_interacting: NodePath) -> void:
	is_grabbed = grabbed
	
	if grabbed:
		player = get_node(player_interacting)
		var id = int(player.name)
		
		set_multiplayer_authority(id)
		if is_multiplayer_authority():
			player.is_camera_locked = true
			virtual_mouse_pos = Vector2(100, 0)
	else:
		if is_multiplayer_authority() and player != null:
			player.is_camera_locked = false
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		player = null
		set_multiplayer_authority(1)

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
		
		if is_vent:
			valve_mesh.rotation.z = clamp(valve_mesh.rotation.z + (change * (crank_sensitivity * sensitivity_multiplier)), deg_to_rad(min_rotation), deg_to_rad(max_rotation))
			var current_frame_value = clamp(remap(valve_mesh.rotation.z, deg_to_rad(max_rotation), deg_to_rad(min_rotation), 1.0, 0.0), 0.0, 1.0)
			value = min(value, current_frame_value)
			#print(value)
		else:
			valve_mesh.rotation.z = clamp(valve_mesh.rotation.z + (change * (crank_sensitivity * sensitivity_multiplier)), deg_to_rad(min_rotation), deg_to_rad(max_rotation))
			value = clamp(remap(valve_mesh.rotation.z, deg_to_rad(min_rotation), deg_to_rad(max_rotation), 0.0, 1.0), 0.0, 1.0)
	
	if Input.is_action_just_released("interact"):
		_multiplayer_manager.rpc(false, "")
