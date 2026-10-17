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
@export var ENGINE_POWER: float = 2750
@export var MAX_STEER: float = 0.25

@export_subgroup("Engine")
@export var max_speed: float = 30.0
@export var throttle_charge_duration: float = 4
var throttle: float = 0.0
var is_engine_on: bool = false

@export_subgroup("Pitch")










#input
var throttle_input: float
var pitch_input: float
var roll_input: float
var yaw_input: float
var steer_input: float




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
	
	_controls(delta)
	_testing()
	
	
	##VISUALS
	elevators.rotation.x = lerp(elevators.rotation.x, pitch_input * deg_to_rad(angle), delta * 5)
	
	left_aileron.rotation.x = lerp(left_aileron.rotation.x, roll_input * deg_to_rad(angle), delta * 5)
	right_aileron.rotation.x = -left_aileron.rotation.x
	
	rudder.rotation.y = lerp(rudder.rotation.y, yaw_input * deg_to_rad(angle), delta * 5)
	print(rad_to_deg(rudder.rotation.y))
	
	##MULTIPLAYER
	#if not player_id or get_multiplayer_authority() != player_id or not is_multiplayer_authority():
		#return
	#
	#pilot.global_position = pilot_seat.global_position
	#pilot.global_rotation = pilot_seat.global_rotation
	

func _ground_state_manager():
	pass

func _controls(delta: float) -> void:
	throttle = clamp(throttle + ((delta / throttle_charge_duration) * throttle_input), 0.0, 1.0)
	
	if is_grounded:
		#ACCELERATION
		if is_engine_on and linear_velocity.length() <= max_speed:
			brake = 0.0
			engine_force = throttle * ENGINE_POWER
		elif not is_engine_on:
			engine_force = 0
		elif linear_velocity.length() > max_speed:
			brake = 50
		
		#STEERING
		steering = move_toward(steering, steer_input * MAX_STEER, delta * 2)

func _pitch():
	pass

func _testing():
	$ThrottleLabel.text = "Throttle: " + str(floor(throttle * 100)) + "%"
	$EngineLabel.text = "Engine: ON" if is_engine_on else "Engine: OFF"
	$SpeedLabel.text = "Speed: " + str(floor(linear_velocity.length()))
	
	
