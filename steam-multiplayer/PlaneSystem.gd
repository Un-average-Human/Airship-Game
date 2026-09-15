extends CharacterBody3D

@export_category("Plane Data")

@export_subgroup("Parts")
@export var ailerons: Array[MeshInstance3D]
@export var elevators: Array[MeshInstance3D]
@export var propellers: Array[MeshInstance3D]
@export var rudder: MeshInstance3D
@export var all_meshes: Node3D
@export var pilot_seat: Marker3D

@export_subgroup("Stats")
@export var min_flight_speed: float = 5.0
@export var max_flight_speed: float = 10.0
@export var acceleration: float = 6.0
@export var turn_speed = 0.75
@export var pitch_speed: float = 0.5
@export var level_speed: float = 3.0
@export var throttle_delta: float = 30.0

@export var forward_speed: float = 0
var target_speed: float = 0

var turn_input = 0
var pitch_input = 0

var custom_gravity: float = 0.0
var on_ground: bool = true

var smoothed_turn: float = 0.0
var smoothed_pitch: float = 0.0

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

func _stop_piloting():
	if pilot:
		if pilot.has_node("CollisionShape3D"):
			pilot.get_node("CollisionShape3D").disabled = false
		if pilot.has_node("StateMachine"):
			pilot.get_node("StateMachine").change_state("idle")
		
		pilot.reparent(get_parent())
		pilot = null
		player_id = 0

func _get_input(delta):
	if Input.is_action_pressed("throttle_up"):
		target_speed = min(forward_speed + throttle_delta * delta, max_flight_speed)
	if Input.is_action_pressed("throttle_down"):
		var limit = 0 if on_ground else min_flight_speed
		target_speed = max(forward_speed - throttle_delta * delta, limit)
	turn_input = 0
	if forward_speed >= max_flight_speed / 2:
		turn_input = Input.get_axis("roll_right", "roll_left")
	pitch_input = 0
	if not on_ground:
		pitch_input -= Input.get_action_strength("pitch_down")
	if forward_speed >= min_flight_speed:
		pitch_input += Input.get_action_strength("pitch_up")

func _physics_process(delta: float) -> void:
	for propeller in propellers:
		propeller.rotate_object_local(Vector3.FORWARD, forward_speed * 5.0 * delta)
		
	if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		return
	
	if pilot:
		pilot.global_position = pilot_seat.global_position
		
	_get_input(delta)
	
	
	
	#PITCH
	smoothed_pitch = lerp(smoothed_pitch, float(pitch_input), 3.0 * delta)
	if not on_ground:
		rotate_object_local(Vector3.RIGHT, smoothed_pitch * pitch_speed * delta)
	else:
		rotation.x = lerp(rotation.x, 0.0, 5.0 * delta)
	
	#YAW
	smoothed_turn = lerp(smoothed_turn, float(turn_input), 3.0 * delta)
	rotate_y(smoothed_turn * turn_speed * delta)
	
	
	
	#ROLL
	if on_ground:
		all_meshes.rotation.z = lerp(all_meshes.rotation.z, 0.0, level_speed * delta)
	else:
		all_meshes.rotation.z = lerp(all_meshes.rotation.z, smoothed_turn, level_speed * delta)
	
	
	
	#THROTTLE
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)
	velocity = -transform.basis.z * forward_speed
	
	if is_on_floor():
		on_ground = true
		velocity.y -= 1
	else:
		on_ground = false
	
	for propeller in propellers:
		propeller.rotate_object_local(Vector3.FORWARD, target_speed * 3.0 * delta)
	
	
	
	#GRAVITY
	custom_gravity = remap(forward_speed, 0.0, max_flight_speed, 9.8, 0.0)
	velocity.y -= custom_gravity * delta
	
	move_and_slide()
