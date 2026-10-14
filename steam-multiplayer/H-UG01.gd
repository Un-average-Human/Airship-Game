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

@export_category("Visual Effects")
@export_subgroup("Shake and Bobbing")
@export var max_dist_offset: Vector3 = Vector3(0.05, 0.05, 0.05)
@export var max_rot_offset: Vector3 = Vector3(0.5, 0.5, 0.5)

@export_category("Stats")
@export_subgroup("Speed")
@export var throttle_increase: float = 0.025
@export var speed_threshold: float = 25.0
@export var max_speed: float = 40.0
@export var accel_rate: float = 125.0
@export var max_accel: float = 500.0

@export_subgroup("Pitch")
@export var lateral_drag: float = 8000.0
@export var vertical_drag: float = 8000.0
@export var pitch_torque: float = 10000.0

@export var stall_time: float = 3.0
@export var stall_invincibility_time: float = 3.0
@export var stall_recovery_time: float = 5.0
@export var min_stall_pitch: float = 60
@export var max_stall_pitch: float = 120

@export_subgroup("Roll")
@export var roll_torque: float = 16000.0

@export_subgroup("Yaw")

var grounded_wheels: Array[VehicleWheel3D] = []
var is_grounded: bool = true


var can_stall: bool = true
var engine_stalled: bool = false
var stall_invincibility_counter: float = 0.0
var stall_recovery_counter: float = 0.0
var stall_counter: float = 0.0

var gravity: float = 0.0
var acceleration: float = 0.0
var throttle: float = 0.0
var old_throttle: float = throttle
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
	##VISUALS
	elevators.rotation.x = lerp(elevators.rotation.x, pitch_input * deg_to_rad(-angle), delta * 5)
	
	right_aileron.rotation.x = lerp(right_aileron.rotation.x, roll_input * deg_to_rad(angle), delta * 5)
	left_aileron.rotation.x = -right_aileron.rotation.x
	
	rudder.rotation.y = lerp(rudder.rotation.y, yaw_input * deg_to_rad(-angle), delta * 5)
	
	#bobbing and shaking go here
	
	
	
	
	
	##MULTIPLAYER
	#if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		#return
	#
	#pilot.global_position = pilot_seat.global_position
	#pilot.global_rotation = pilot_seat.global_rotation
	
	
	
	## GROUNDED STATE
	var wheels_in_contact: int = 0
	var surface_normal: Vector3
	for wheel: VehicleWheel3D in wheels:
		if wheel.is_in_contact():
			surface_normal = wheel.get_contact_normal()
			if surface_normal.dot(Vector3.UP) > 0.5:
				wheels_in_contact += 1
			
	if wheels_in_contact >= 2:
		is_grounded = true
	elif wheels_in_contact == 0 or linear_velocity.length() >= speed_threshold:
		is_grounded = false
	
	
	
	##THROTTLE
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	if throttle_input != 0.0 and not engine_stalled:
		throttle = clampf(throttle + (throttle_increase * throttle_input), 0.0, 1.0)
	print("Throttle: ", throttle)
	print("Current speed: ", linear_velocity.length())
	#print("Current accel: ", acceleration)
	
	target_speed = remap(throttle, 0.0, 1.0, 0.0, max_speed)
	
	
	
	#DRAG
	var local_vel: Vector3 = global_transform.basis.inverse() * linear_velocity
	
	#multiply by throttle so itll work with the gravity yk?
	var lateral_drag_force: Vector3 = -global_transform.basis.x * (local_vel.x * lateral_drag * throttle)
	var vertical_drag_force: Vector3 = -global_transform.basis.y * (local_vel.y * vertical_drag * throttle)
	
	apply_central_force(lateral_drag_force)
	if linear_velocity.length() >= speed_threshold and pitch_input != 0:
		apply_central_force(vertical_drag_force)
	
	
	
	#ACCELERATION
	var target_max_accel = remap(throttle, 0.0, 1.0, 0.0, max_accel)
	acceleration = clampf(acceleration + (throttle * accel_rate * delta), 0.0, target_max_accel)
	
	var forward_dir: Vector3
	if is_grounded:
		forward_dir = Vector3(-global_transform.basis.z.x, 0.0, -global_transform.basis.z.z)
	else:
		forward_dir = -global_transform.basis.z
	
	apply_central_force(forward_dir * target_speed * acceleration)
	
	#i cant just use linear_velocity = linear_velocity.limit_length(max_speed)
	#because the wheels clip into the ground for some god forsaken reason
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.limit_length(max_speed)
	
	
	
	#BRAKE
	if throttle == 0.0 and linear_velocity.length() > 0 and is_grounded:
		for wheel: VehicleWheel3D in wheels:
			wheel.brake = 50.0 
	else:
		for wheel: VehicleWheel3D in wheels:
			wheel.brake = 0.0
	
	
	
	##GRAVITY (may not be necessary (it was necessary))
	#if not is_grounded:
	gravity_scale = remap(linear_velocity.length(), 0.0, max_speed, 1.5, 1.0)
	if linear_velocity.length() >= speed_threshold:
		gravity = remap(linear_velocity.length(), speed_threshold, max_speed, 0.0, -get_gravity().y * mass)
	apply_central_force(Vector3.UP * gravity)
	
	
	
	##PITCH
	#this makes so when youre grounded you can only pitch up
	if is_grounded:
		pitch_input = Input.get_action_strength("pitch_up")
	else:
		pitch_input = Input.get_axis("pitch_down", "pitch_up")
	
	apply_torque(global_transform.basis.x * pitch_input * pitch_torque)
	
	
	
	##ROLL
	roll_input = Input.get_axis("roll_right", "roll_left")
	if not is_grounded:
		apply_torque(global_transform.basis.z * roll_input * roll_torque)
	
	
	
	##YAW
	yaw_input = Input.get_axis("yaw_right", "yaw_left")
	
	
	
	##STALL
	if rotation.x > deg_to_rad(min_stall_pitch) and rotation.x < deg_to_rad(max_stall_pitch):
		print("can stall")
		if not engine_stalled and can_stall:
			can_stall = false
			engine_stalled = true
			old_throttle = throttle
			throttle = 0.0
			
	if engine_stalled:
		stall_recovery_counter += delta
		if stall_recovery_counter >= stall_recovery_time:
			engine_stalled = false
			throttle = old_throttle
			stall_recovery_counter = 0.0
			stall_invincibility_counter = stall_invincibility_time
			
	elif not engine_stalled and not can_stall:
		stall_invincibility_counter -= delta
		if stall_invincibility_counter <= 0.0:
			can_stall = true
			stall_invincibility_counter = 0.0
