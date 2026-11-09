@icon("uid://b41c6dwvtv4qm")
extends AnimatableBody3D
class_name Helm

@export var pilot_seat: RemoteTransform3D
@export var camera: Camera3D

var is_grabbed: bool = false
var player: CharacterBody3D
var player_pos_tween

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
