extends VehicleBody3D

@export_category("Exterior Mechanisms and Instruments")
@export_subgroup("Aerodynamic Components")
@export var angle: float = 30
@export var elevators: MeshInstance3D
@export var right_aileron: MeshInstance3D
@export var left_aileron: MeshInstance3D
@export var rudder: MeshInstance3D


@export_subgroup("Mechanical Components")
@export var propellers: Array[MeshInstance3D]
@export var tail_wheel: Node3D
@export var guns: Array[MeshInstance3D]
@export var wheels: Array[VehicleWheel3D]



@export_category("Stats")
@export_subgroup("Speed")
@export var throttle_increase: float = 0.025
@export var speed_threshold: float = 10.0
@export var max_speed: float = 20.0
@export var accel_rate: float = 20.0
@export var max_accel: float = 150

@export_subgroup("Pitch")
@export var lateral_drag: float = 5000.0
@export var vertical_drag: float = 5000.0
@export var pitch_torque: float = 2000

@export_subgroup("Roll")
@export var roll_torque: float = 2000

@export_subgroup("Yaw")

var grounded_wheels: Array[VehicleWheel3D] = []
var is_grounded: bool = true

var gravity: float = 0.0
var acceleration: float = 0.0
var throttle: float = 0.0
var target_speed: float = 0.0

#input
var throttle_input: float
var pitch_input: float
var roll_input: float
var yaw_input: float

@export_category("Multiplayer")
@export var multiplayer_synchronizer: MultiplayerSynchronizer
@export var player_id: int

var pilot: CharacterBody3D



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
	elevators.rotation.x = lerp(elevators.rotation.x, pitch_input * deg_to_rad(-angle), delta * 5)
	
	right_aileron.rotation.x = lerp(right_aileron.rotation.x, roll_input * deg_to_rad(angle), delta * 5)
	left_aileron.rotation.x = -right_aileron.rotation.x
	
	
	#if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		#return
	#
	#pilot.global_position = pilot_seat.global_position
	#pilot.global_rotation = pilot_seat.global_rotation
	
	## GROUNDED STATE
	var wheels_in_contact: int = 0
	for wheel: VehicleWheel3D in wheels:
		if wheel.is_in_contact():
			wheels_in_contact += 1
			
	if wheels_in_contact >= 2:
		is_grounded = true
	elif wheels_in_contact == 0:
		is_grounded = false
	
	##THROTTLE
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	if throttle_input != 0.0:
		throttle = clampf(throttle + (throttle_increase * throttle_input), 0.0, 1.0)
		#print("Throttle: ", throttle)
	#print("Current speed: ", linear_velocity.length())
	#print("Current accel: ", acceleration)
	
	target_speed = remap(throttle, 0.0, 1.0, 0.0, max_speed)
	
	#DRAG
	var local_vel: Vector3 = global_transform.basis.inverse() * linear_velocity
	
	#multiply by throttle so itll work with the gravity yk?
	var lateral_drag_force: Vector3 = -global_transform.basis.x * (local_vel.x * lateral_drag * throttle)
	var vertical_drag_force: Vector3 = -global_transform.basis.y * (local_vel.y * vertical_drag * throttle)
	
	apply_central_force(lateral_drag_force)
	apply_central_force(vertical_drag_force)
	
	#ACCELERATION
	var target_max_accel = remap(throttle, 0.0, 1.0, 0.0, max_accel)
	acceleration = clampf(acceleration + (throttle * accel_rate * delta), 0.0, target_max_accel)
	
	apply_central_force(-global_transform.basis.z * target_speed * acceleration)
	
	#i cant just use linear_velocity = linear_velocity.limit_length(max_speed) 
	#because the wheels clip into the ground for some god forsaken reason
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.limit_length(max_speed)
	
	##GRAVITY (may not be necessary (it was necessary))
	gravity_scale = remap(linear_velocity.length(), 0.0, max_speed, 2, 1.0)
	gravity = remap(linear_velocity.length(), speed_threshold, max_speed, 0.0, get_gravity().y)
	apply_central_force(Vector3.UP * gravity)
	
	##PITCH
	#this makes so when youre grounded you can only pitch up
	if is_grounded:
		pitch_input = Input.get_action_strength("pitch_up")
	else:
		pitch_input = Input.get_axis("pitch_down", "pitch_up")
	apply_torque(global_transform.basis.x * pitch_input * pitch_torque)
	
	##ROLL
	if not is_grounded:
		roll_input = Input.get_axis("roll_right", "roll_left")
	apply_torque(global_transform.basis.z * roll_input * roll_torque)
	
	##YAW
	yaw_input = Input.get_axis("yaw_right", "yaw_left")

func _manage_plane_states():
	if is_grounded:
		pass
