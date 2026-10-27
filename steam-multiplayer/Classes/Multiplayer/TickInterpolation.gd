extends Node
class_name TickInterpolation

@export var objects_to_sync: Array
@export var interpolation_delay: float = 100.0 #in milliseconds

var parent: Node #gets whats being updated and uses the choppy movement to smooth it
var buffer: Array[Dictionary] #stores packet data, such as when it arrived, position and rotation

func _ready() -> void:
	#check if player is multiplayer authority and stop if they are (only want to update the movement from OTHER players)
	#and if they are simply stop the code from running for them since it'll already be smooth for em
	if is_multiplayer_authority() or objects_to_sync.is_empty():
		set_process(false)
		return
	
	parent = get_parent()

func _process(delta: float) -> void:
	pass
