@icon("uid://b41c6dwvtv4qm")
extends AnimatableBody3D
class_name Helm

@export var pilot_seat: RemoteTransform3D

var is_grabbed: bool = false
var player: CharacterBody3D
var player_pos_tween

func _ready() -> void:
	pass # Replace with function body.

func execute(player_interacting: CharacterBody3D):
	player = player_interacting
	
	if not is_grabbed:
		_manage_player_pos(false)
	else:
		_manage_player_pos(true)

func _manage_player_pos(is_leaving: bool):
	if is_leaving:
		pilot_seat.remote_path = ""
		player.rotation = Vector3.ZERO
		
		player.can_move = true
		player = null
		is_grabbed = false
	else:
		player.can_move = false
		
		player.global_position = pilot_seat.global_position
		pilot_seat.remote_path = player.get_path()
		
		is_grabbed = true
