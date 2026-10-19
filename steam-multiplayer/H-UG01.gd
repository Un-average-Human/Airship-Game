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




@export_category("Controls")

@export var MAX_STEER: float = 0.25
@export var ENGINE_POWER: float = 8000

@export_subgroup("Speed")
@export var max_speed: float = 30.0
@export var flight_speed_threshold: float = 20.0
@export var throttle_charge_duration: float = 2
var throttle: float = 0.0
var is_engine_on: bool = false

@export_subgroup("Pitch")
@export var pitch_torque: float = 7500
@export var pitch_strength: float = 500
var current_pitch_torque: float

@export var drag_factor_time: float = 4.0
var drag_factor: float = 0.0










#input
var throttle_input: float
var pitch_input: float
var roll_input: float
var yaw_input: float
var steer_input: float




#grounded state
var gravity
var is_grounded: bool = true

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




func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("start_engine"):
		is_engine_on = !is_engine_on




func _physics_process(delta: float) -> void:
	##INPUTS
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	pitch_input = Input.get_axis("pitch_down", "pitch_up")
	roll_input = Input.get_axis("roll_left", "roll_right")
	yaw_input = Input.get_axis("yaw_left", "yaw_right")
	steer_input = Input.get_axis("steer_left", "steer_right")
	
	##GRAVITY
	gravity = remap(linear_velocity.length(), 0.0, max_speed, 0.0, 10 * mass)
	apply_central_force(Vector3.UP * gravity)
	
	_ground_state_manager()
	_controls(delta)
	_testing()
	
	##VISUALS
	elevators.rotation.x = lerp(elevators.rotation.x, pitch_input * deg_to_rad(-angle), delta * 5)
	
	left_aileron.rotation.x = lerp(left_aileron.rotation.x, roll_input * deg_to_rad(angle), delta * 5)
	right_aileron.rotation.x = -left_aileron.rotation.x
	
	rudder.rotation.y = lerp(rudder.rotation.y, yaw_input * deg_to_rad(angle), delta * 5)
	
	##MULTIPLAYER
	#if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		#return
	#
	#pilot.global_position = pilot_seat.global_position
	#pilot.global_rotation = pilot_seat.global_rotation
	

func _ground_state_manager():
	var wheels_in_contact: int = 0
	for wheel: VehicleWheel3D in wheels:
		if wheel.is_in_contact():
			var surface_normal = wheel.get_contact_normal()
			if surface_normal.dot(Vector3.UP) > 0.5:
				wheels_in_contact += 1
	
	if wheels_in_contact == 0:
		is_grounded = false
	
	elif wheels_in_contact >= 2:
		is_grounded = true



func _controls(delta: float) -> void:
	throttle = clamp(throttle + ((delta / throttle_charge_duration) * throttle_input), 0.0, 1.0)
	
	if is_grounded:
		if linear_velocity.length() > max_speed:
			brake = 50
		
		#STEERING
		var speed_factor: float = remap(linear_velocity.length(), 0.0, flight_speed_threshold, 1.0, 0.05)
		steering = lerp(steering, steer_input * (MAX_STEER * speed_factor), delta * 5)
	
	else:
		#PITCH
		current_pitch_torque = move_toward(current_pitch_torque, pitch_torque * pitch_input, pitch_strength)
		print("Current Torque: ", current_pitch_torque)
		apply_torque(global_transform.basis.x * current_pitch_torque)

	if is_engine_on:
		#ACCELERATION
		var target_speed = throttle * ENGINE_POWER
		apply_central_force(-global_transform.basis.z * target_speed)
		if linear_velocity.length() > max_speed:
			linear_velocity = linear_velocity.limit_length(max_speed)
		
		if not is_grounded:
			if pitch_input == 0:
				drag_factor = lerp(drag_factor, 0.0, (5 / drag_factor_time) * delta)
			else:
				drag_factor = lerp(drag_factor, 7.5, (5 / drag_factor_time) * delta * abs(pitch_input))
			apply_central_force(-global_transform.basis.y * linear_velocity.dot(global_transform.basis.y) * mass * drag_factor)

func _testing():
	$ThrottleLabel.text = "Throttle: " + str(floor(throttle * 100)) + "%"
	$EngineLabel.text = "Engine: ON" if is_engine_on else "Engine: OFF"
	$SpeedLabel.text = "Speed: " + str(floor(linear_velocity.length()))
	$GroundedLabel.text = "Grounded: TRUE" if is_grounded else "Grounded: FALSE"
	$GravityLabel.text = "Gravity: " + str(floor(gravity / mass))
	$DragFactorLabel.text = "Drag Factor: " + str(floor(drag_factor))
	
