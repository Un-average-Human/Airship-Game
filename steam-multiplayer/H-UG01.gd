extends RigidBody3D

@export_category("Stats")
@export_subgroup("Speed")
@export var throttle_increase: float = 0.025
@export var max_speed: float = 20.0
@export var accel_rate: float = 20.0
@export var max_accel: float = 150

@export_subgroup("Pitch")
@export var lateral_drag: float = 5000.0
@export var vertical_drag: float = 5000.0
@export var pitch_torque: float = 2500

var acceleration: float = 0.0
var throttle: float = 0.0
var target_speed: float = 0.0

var throttle_input
var pitch_input

func _physics_process(delta: float) -> void:
	##THROTTLE
	throttle_input = Input.get_axis("throttle_down", "throttle_up")
	if throttle_input != 0.0:
		throttle = clampf(throttle + (throttle_increase * throttle_input), 0.0, 1.0)
	
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
	acceleration = clampf(acceleration + (throttle_input * accel_rate * delta), 0.0, target_max_accel)
	if throttle_input == 0.0:
		acceleration = move_toward(acceleration, 0.0, accel_rate * delta)
	
	apply_central_force(-global_transform.basis.z * target_speed * acceleration)
	
	if linear_velocity.length() > max_speed:
		linear_velocity = linear_velocity.normalized() * max_speed
	
	##GRAVITY
	gravity_scale = remap(throttle, 0.0, 1.0, 1.0, 0.0)
	
	##PITCH
	pitch_input = Input.get_axis("pitch_down", "pitch_up")
	apply_torque(global_transform.basis.x * pitch_input * pitch_torque)
