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
var player: PhysicsBody3D
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

func execute(player_interacting: Player):
	player = player_interacting
	
	if not is_grabbed:
		var id = int(player.name)
		set_multiplayer_authority(id)
		
		_manage_player_pos(false)
	else:
		_manage_player_pos(true)

func _manage_player_pos(is_leaving: bool):
	if not is_multiplayer_authority():
		return
	if is_leaving:
		player.camera.make_current()
		is_grabbed = false
		pilot_seat.remote_path = ""
		player.rotation.z = 0.0
		player.rotation.x = 0.0
		
		if player is RigidBody3D:
			player.freeze = false
		
		player.can_move = true
		player.is_camera_locked = false
		player = null
		set_multiplayer_authority(1)
	else:
		if player is RigidBody3D:
			player.freeze = true
			
		player.can_move = false
		player.is_camera_locked = true
		player.rotation = Vector3.ZERO
		
		pilot_seat.remote_path = player.get_path()
		player.neck.rotation = Vector3.ZERO
		player.global_transform = pilot_seat.global_transform
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
	_sync_helm.rpc(helm_mesh.rotation.z, value)

@rpc("any_peer", "call_local", "unreliable_ordered")
func _sync_helm(rot_z: float, new_val: float) -> void:
	helm_mesh.rotation.z = rot_z
	value = new_val
