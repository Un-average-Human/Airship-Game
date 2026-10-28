extends Node
class_name TickInterpolation

@export var objects_to_sync: Node
@export var interpolation_delay: float = 100.0 #in milliseconds

var world_state_buffer: Array[Dictionary] #stores packet data, such as when it arrived, position and rotation

func _ready() -> void:
	#check if player is multiplayer authority and stop if they are (only want to update the movement from OTHER players)
	#and if they are simply stop the code from running for them since it'll already be smooth for em
	if is_multiplayer_authority():
		var world_state_dict: Dictionary = {
			"position": objects_to_sync.position,
			"rotation": objects_to_sync.rotation,
			"time": Time.get_ticks_msec()
		}

func _physics_process(delta: float) -> void:
	pass
		
