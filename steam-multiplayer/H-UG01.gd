extends VehicleBody3D

@export_category("Stats")
@export_subgroup("Speed")
@export var throttle_increase: float = 0.025
@export var max_speed: float = 20.0
@export var accel_rate: float = 20.0
@export var max_accel: float = 150

@export_subgroup("Pitch")
@export var lateral_drag: float = 5000.0
@export var vertical_drag: float = 5000.0
@export var pitch_torque: float = 2000

@export_subgroup("Roll")
@export var roll_torque: float = 2000

var gravity: float = 0.0
var acceleration: float = 0.0
var throttle: float = 0.0
var target_speed: float = 0.0

var throttle_input: float
var pitch_input: float
var roll_input: float

@export var player_id: int
@export var multiplayer_synchronizer: MultiplayerSynchronizer
@export var pilot_seat: Marker3D

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
	if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		return
	
	pilot.global_position = pilot_seat.global_position
	pilot.global_rotation = pilot_seat.global_rotation
	
	##THROTTLE
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	if throttle_input != 0.0:
		throttle = clampf(throttle + (throttle_increase * throttle_input), 0.0, 1.0)
		print("Throttle: ", throttle)
	print("Current speed: ", linear_velocity.length())
	print("Current accel: ", acceleration)
	
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
	
	##GRAVITY (may not be necessary
	gravity = remap(linear_velocity.length(), 0.0, max_speed, 0.0, get_gravity().y)
	apply_central_force(Vector3.UP * gravity)
	
	##PITCH
	pitch_input = Input.get_axis("pitch_down", "pitch_up")
	apply_torque(global_transform.basis.x * pitch_input * pitch_torque)
	
	##ROLL
	roll_input = Input.get_axis("roll_right", "roll_left")
	apply_torque(global_transform.basis.z * roll_input * roll_torque)
