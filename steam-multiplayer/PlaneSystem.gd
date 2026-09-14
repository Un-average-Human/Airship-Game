extends RigidBody3D

@export_category("Plane Data")

@export_subgroup("Moving Parts")
@export var ailerons: Array[MeshInstance3D]
@export var elevators: Array[MeshInstance3D]
@export var propellers: Array[MeshInstance3D]
@export var rudder: MeshInstance3D

@export_subgroup("Stats")
@export var max_speed: float = 20.0
@export var acceleration: float = 5.0
@export var roll_torque = 150
@export var pitch_torque = 1200

@export var pilot_seat: Marker3D

var plane_gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var throttle: float = 0.0

var custom_gravity: float = 0.0

#player
@export_subgroup("Player")
@export var player_id: int
@export var multiplayer_synchronizer: MultiplayerSynchronizer

var pilot: CharacterBody3D

#FUNCTIONS
func execute(player: CharacterBody3D):
	pilot = player
	
	if player.has_node("StateMachine"):
		player.get_node("StateMachine").change_state("sitting")
		
	_manage_authority.rpc(int(player.name))
	_start_piloting()

@rpc("any_peer", "call_local", "reliable")
func _manage_authority(driver_id: int):
	player_id = driver_id
	
	#update synchroniser so it sends data from the correct player
	set_multiplayer_authority(driver_id)
	multiplayer_synchronizer.set_multiplayer_authority(driver_id)


func _start_piloting():
	if pilot and pilot.has_node("CollisionShape3D"):
		pilot.get_node("CollisionShape3D").disabled = true
	
		pilot.reparent(pilot_seat)
		pilot.global_position = pilot_seat.global_position

func _stop_piloting():
	if pilot:
		if pilot.has_node("CollisionShape3D"):
			pilot.get_node("CollisionShape3D").disabled = false
		if pilot.has_node("StateMachine"):
			pilot.get_node("StateMachine").change_state("idle")
		
		pilot.reparent(get_parent())
		pilot = null
		player_id = 0

func _physics_process(delta: float) -> void:
	if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		return
	
	#THROTTLE CONTROLS
	var throttle_input = Input.get_axis("throttle_down", "throttle_up")
	throttle = clamp(throttle + throttle_input * delta, 0.0, 1.0)
	
	var target_speed = throttle * max_speed
	var current_forward_speed: float = -global_transform.basis.z.dot(linear_velocity)
	
	if current_forward_speed < target_speed:
		var thrust_force: float = mass * acceleration
		apply_central_force(-global_transform.basis.z * thrust_force)
	
	#DRAG
	var local_velocity = global_transform.basis.inverse() * linear_velocity
	
	var wing_grip: float = 4.0
	local_velocity.x *= exp(-wing_grip * delta)
	local_velocity.y *= exp(-wing_grip * delta)
	
	linear_velocity = global_transform.basis * local_velocity

	#PITCH
	var pitch_input = Input.get_axis("pitch_down", "pitch_up")
	apply_torque(transform.basis.x * pitch_input * pitch_torque)
	
	#ROLL
	var roll_input = Input.get_axis("roll_right", "roll_left")
	apply_torque(transform.basis.z * roll_input * roll_torque)
	
	#GRAVITY
	custom_gravity = remap(throttle, 0.0, 1.0, 0.0, plane_gravity)
	apply_central_force(Vector3.UP * custom_gravity * mass)
