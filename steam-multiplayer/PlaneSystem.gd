extends RigidBody3D

@export_category("Plane Data")

@export_subgroup("Moving Parts")
@export var ailerons: Array[MeshInstance3D]
@export var elevators: Array[MeshInstance3D]
@export var propellers: Array[MeshInstance3D]
@export var rudder: MeshInstance3D

@export_subgroup("Stats")
@export var max_speed: float = 30.0
@export var acceleration: float = 10.0
@export var roll_torque = 1200
@export var pitch_torque = 1250

var plane_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var throttle: float = 0.0

var custom_gravity: float = 0.0

#player
@export var player_id: int
@onready var multiplayer_synchronizer: MultiplayerSynchronizer = $MultiplayerSynchronizer

#FUNCTIONS
@rpc("any_peer", "call_local", "reliable")
func execute(driver_id: int):
	player_id = driver_id
	
	#update synchroniser so it sends data from the correct player
	set_multiplayer_authority(driver_id)
	multiplayer_synchronizer.set_multiplayer_authority(driver_id)
		
	_start_piloting()


func _start_piloting():
	pass

func _stop_piloting():
	pass

func _physics_process(delta: float) -> void:
	if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		return
	
	#THROTTLE CONTROLS
	var throttle_input = Input.get_axis("throttle_down", "throttle_up")
	throttle = clamp(throttle + throttle_input * delta, 0.0, 1.0)
	
	var target_speed = throttle * max_speed
	
	var current_forward_speed: float = -global_transform.basis.z.dot(linear_velocity)
	print(current_forward_speed, " ", throttle)
	
	if current_forward_speed < target_speed:
		var thrust_force: float = mass * acceleration
		apply_central_force(-global_transform.basis.z * thrust_force)
	
	#PITCH CONTROLS
	var pitch_input = Input.get_axis("pitch_down", "pitch_up")
	apply_torque(transform.basis.x * pitch_input * pitch_torque)
	
	#ROLL CONTROLS
	var roll_input = Input.get_axis("move_right", "move_left")
	apply_torque(transform.basis.z * roll_input * roll_torque)
	
	#gravity (grave verity?!)
	custom_gravity = remap(throttle, 0.0, 1.0, 0.0, plane_gravity)
	apply_central_force(Vector3.UP * custom_gravity * mass)
