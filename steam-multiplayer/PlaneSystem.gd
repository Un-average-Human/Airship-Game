extends RigidBody3D

@export_category("Plane Data")

@export_subgroup("Moving Parts")
@export var ailerons: Array[MeshInstance3D]
@export var elevators: Array[MeshInstance3D]
@export var propellers: Array[MeshInstance3D]
@export var rudder: MeshInstance3D

@export_subgroup("Stats")
@export var max_speed: float = 0.5

var plane_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var throttle: float = 0.0

var custom_gravity: float = 0.0
var frame_speed: float = 0.0 

#player
var player_id: int



#FUNCTIONS
@rpc("any_peer", "call_local", "reliable")
func execute(driver_id: int):
	player_id = driver_id
	
	set_multiplayer_authority(driver_id)
	
	#update synchroniser so it sends data from the correct player
	if has_node("MultiplayerSynchronizer"):
		$MultiplayerSynchronizer.set_multiplayer_authority(driver_id)
		
	_start_piloting()

func _start_piloting():
	pass

func _stop_piloting():
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_pressed("throttle_up") and throttle <= 1.0:
		throttle += 1 * delta
	elif Input.is_action_pressed("throttle_down") and throttle > 0:
		throttle -= 1 * delta
	
	custom_gravity = remap(throttle, 0.0, 1.0, 0.0, plane_gravity)
	frame_speed = remap(throttle, 0.0, 1.0, 0.0, max_speed)
	
	var thrust_force: float = mass * (frame_speed / delta)
	
	apply_central_force(-global_transform.basis.z * thrust_force)
	apply_central_force(Vector3.UP * custom_gravity * mass)
