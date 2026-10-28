extends Node3D
class_name TickInterpolation3D

@export var object_updating: Node3D
@export var multiplayer_synchronizer: MultiplayerSynchronizer #using this to update when a new packet arrives
@export var interpolation_delay: float = 100.0 #in milliseconds

var world_state_buffer: Array[Dictionary] #stores packet data, such as when it arrived, position and rotation


func _ready() -> void:
	global_transform = object_updating.global_transform
	
	
	#check if player is multiplayer authority and stop if they are (only want to update the movement from OTHER players)
	#and if they are simply stop the code from running for them since it'll already be smooth for em
	multiplayer_synchronizer.synchronized.connect(synchronizer_updated)
	if not object_updating.is_multiplayer_authority():
		top_level = true

func synchronizer_updated():
	#take a snap of the current data and save it to the buffer
	var data_snapshot: Dictionary = {
		"time": Time.get_ticks_msec(),
		"position": object_updating.global_position,
		"rotation": object_updating.global_rotation
	}
	world_state_buffer.append(data_snapshot)

func _process(delta: float) -> void:
	#mesh will automatically follow its parent and wont proceed if the player is the multiplayer authority
	top_level = not object_updating.is_multiplayer_authority()
	if object_updating.is_multiplayer_authority():
		return
	
	
	var render_time: float = Time.get_ticks_msec() - interpolation_delay
	if world_state_buffer.size() > 1:
		while world_state_buffer.size() > 2 and render_time > world_state_buffer[1]["time"]:
			world_state_buffer.remove_at(0)
