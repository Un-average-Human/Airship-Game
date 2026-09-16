extends RigidBody3D

@export_category("Plane Data")

@export_subgroup("Parts")
@export var ailerons: Array[Node3D]
@export var elevators: Array[Node3D]
@export var propellers: Array[Node3D]
@export var rudder: Node3D
@export var all_meshes: Node3D
@export var pilot_seat: Marker3D

@export_subgroup("Stats")
@export var acceleration: float = 0.05
@export var max_engine_power: float = 75
@export var max_flight_speed: float = 10.0
@export var roll_torque: float = 120000000
@export var pitch_torque: float = 120000000

#player
@export_subgroup("Player")
@export var player_id: int
@export var multiplayer_synchronizer: MultiplayerSynchronizer

@export_subgroup("Stuff That Needs To Be Synced")
@export var current_speed: float = 0

@export var roll_input: float = 0
@export var pitch_input: float = 0
@export var throttle_input: float = 0

@export var throttle: float = 0.0

@export var forwards_speed: Vector3

var engine_power: float

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



func _physics_process(delta: float) -> void:
	if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		return
	
	pilot.global_position = pilot_seat.global_position
	
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	throttle = clampf(throttle + (throttle_input * 0.5 * delta), 0.0, 1.0)
	
	var target_engine_power: float = remap(throttle, 0.0, 1.0, 0.0, max_engine_power)
	engine_power = lerp(engine_power, target_engine_power, acceleration)
	
	gravity_scale = remap(throttle, 0.0, 1.0, 1.0, 0.0)
	print(gravity_scale)
	
	roll_input = Input.get_axis("roll_right", "roll_left")
	pitch_input = Input.get_axis("pitch_down", "pitch_up")
	
	current_speed = remap(throttle, 0.0, 1.0, 0.0, max_flight_speed)
	
	apply_torque(transform.basis.x * pitch_input * pitch_torque)
	apply_torque(transform.basis.z * roll_input * roll_torque)
	forwards_speed = current_speed * -global_transform.basis.z * engine_power
	apply_central_force(forwards_speed)

	if linear_velocity.length() > max_flight_speed:
			linear_velocity = linear_velocity.normalized() * max_flight_speed
