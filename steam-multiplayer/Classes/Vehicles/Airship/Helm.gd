@icon("uid://b41c6dwvtv4qm")
extends AnimatableBody3D
class_name Helm

@export var pilot_seat: RemoteTransform3D
@export var camera: Camera3D
@export var helm_mesh: Node3D


@export var rotation_speed: float = 2.5
@export var max_helm_rot: float = 360
@export var min_helm_rot: float = -360

var is_grabbed: bool = false
var player: CharacterBody3D
var player_pos_tween

var value: float

func _ready() -> void:
	pass # Replace with function body.

func _unhandled_input(event: InputEvent) -> void:
	if not is_grabbed:
		return
	
	if event is InputEventMouseMotion:
		camera.rotate_y(-event.relative.x * 0.005)
		camera.rotation.y = clamp(camera.rotation.y, deg_to_rad(-60), deg_to_rad(60))

func execute(player_interacting: CharacterBody3D):
	player = player_interacting
	
	if not is_grabbed:
		_manage_player_pos(false)
	else:
		_manage_player_pos(true)

func _manage_player_pos(is_leaving: bool):
	if is_leaving:
		player.camera.make_current()
		is_grabbed = false
		pilot_seat.remote_path = ""
		player.rotation = Vector3.ZERO
		
		player.can_move = true
		player.is_camera_locked = false
		player = null
	else:
		player.can_move = false
		player.is_camera_locked = true
		player.rotation = Vector3.ZERO
		
		player.global_position = pilot_seat.global_position
		pilot_seat.remote_path = player.get_path()
		camera.make_current()
		
		is_grabbed = true

func _physics_process(delta: float) -> void:
	if not is_grabbed:
		return
	
	var steer_input = Input.get_axis("steer_left", "steer_right")
	helm_mesh.rotation.z = clampf(helm_mesh.rotation.z + (deg_to_rad(rotation_speed) * steer_input), deg_to_rad(min_helm_rot), deg_to_rad(max_helm_rot))
	
	value = remap(helm_mesh.rotation.z, deg_to_rad(min_helm_rot), deg_to_rad(max_helm_rot), 1, -1)
	if absf(value) < 0.02:
		value = 0.0
	print(value)
