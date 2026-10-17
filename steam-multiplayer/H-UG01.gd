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

@export_subgroup("Grounded")
@export var ENGINE_POWER: float = 3000
@export var MAX_STEER: float = 0.9

@export_subgroup("Throttle")
@export var throttle_charge_duration: float = 4
var throttle: float










#input
var throttle_input: float
var pitch_input: float
var roll_input: float
var yaw_input: float




#grounded state
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


func _physics_process(delta: float) -> void:
	##INPUTS
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	pitch_input = Input.get_axis("pitch_down", "pitch_up")
	roll_input
	yaw_input
	
	_throttle(delta)
	_control()
	_testing()
	
	
	##VISUALS
	elevators.rotation.x = lerp(elevators.rotation.x, pitch_input * deg_to_rad(-angle), delta * 5)
	
	right_aileron.rotation.x = lerp(right_aileron.rotation.x, roll_input * deg_to_rad(angle), delta * 5)
	left_aileron.rotation.x = -right_aileron.rotation.x
	
	rudder.rotation.y = lerp(rudder.rotation.y, yaw_input * deg_to_rad(-angle), delta * 5)
	
	##MULTIPLAYER
	#if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		#return
	#
	#pilot.global_position = pilot_seat.global_position
	#pilot.global_rotation = pilot_seat.global_rotation
	

func _ground_state_manager():
	pass

func _throttle(delta: float) -> void:
	throttle = clamp(throttle + ((delta / throttle_charge_duration) * throttle_input), 0.0, 1.0)

func _control():
	if is_grounded:
		engine_force = throttle * ENGINE_POWER

func _start_engine():
	pass

func _testing():
	$ThrottleLabel.text = "Throttle: " + str(floor(throttle * 100)) + "%"
