extends RigidBody3D

@export_category("Stats")
@export_subgroup("Speed")
@export var throttle_increase: float = 0.025
@export var max_speed: float = 20.0
@export var accel_rate: float = 20.0
@export var max_accel: float = 150

@export_subgroup("Pitch")
@export var pitch_torque: float = 150

var acceleration: float = 0.0
var throttle: float = 0.0
var target_speed: float = 0.0
var current_speed: float = 0.0

var throttle_input
var pitch_input

func _physics_process(delta: float) -> void:
	##THROTTLE
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	if throttle_input != 0.0:
		throttle = clampf(throttle + (throttle_increase * throttle_input), 0.0, 1.0)
		print("Throttle: ", throttle * 100, "%")
		print("Target Speed: ", target_speed, "m/s")
		print("Velocity is: ", linear_velocity.z)
	
	target_speed = remap(throttle, 0.0, 1.0, 0.0, max_speed)
	physics_material_override.friction = remap(throttle, 0.0, 1.0, 1.0, 0.0)
	
	#ACCELERATION
	var target_max_accel = remap(throttle, 0.0, 1.0, 0.0, max_accel)
	acceleration = clampf(acceleration + (throttle_input * accel_rate * delta), 0.0, target_max_accel)
	if throttle_input == 0.0:
		acceleration = move_toward(acceleration, 0.0, accel_rate * delta)
	
	apply_central_force(Vector3.FORWARD * target_speed * acceleration)
	linear_velocity = linear_velocity.limit_length(max_speed)
	
	
	##GRAVITY
	gravity_scale = remap(throttle, 0.0, 1.0, 1.0, 0.0)
	
	
	##PITCH
	pitch_input = Input.get_axis("pitch_down", "pitch_up")
	
