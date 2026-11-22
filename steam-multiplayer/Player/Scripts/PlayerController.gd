extends CharacterBody3D
class_name Player

# Physics
@export var mass_ratio_multi: float = 1.4
@export var mass: float = 80
const PHYSICS_MASS: float = 80

# Camera
@export_subgroup("Camera")
@export var neck: Node3D
@export var camera: Camera3D
@export var interact_raycast: RayCast3D

var is_camera_locked: bool = false

# Multiplayer
@export_subgroup("Multiplayer")
@export var multiplayer_compatible: bool

# Movement
@export_subgroup("Movement")
@export var walking_speed: float = 5.0
@export var running_speed: float = 8.0
@export var jump_velocity: float = 4.0

var current_speed = walking_speed
var can_move: bool = true
var platform_vel: Vector3

func _enter_tree() -> void:
	if multiplayer_compatible:
		set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if is_multiplayer_authority():
		camera.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if multiplayer_compatible and not is_multiplayer_authority():
		return

	if Input.is_key_pressed(KEY_ESCAPE):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	if event is InputEventMouseMotion and not is_camera_locked:
		rotate_y(-event.relative.x * 0.005)
		neck.rotate_x(-event.relative.y * 0.005)
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-70), deg_to_rad(70))

	if event.is_action_pressed("interact"):
		if interact_raycast.is_colliding():
			var collider := interact_raycast.get_collider()
			if collider.is_in_group("interactable"):
				collider.execute(self)

func _rigidbody_interaction():
	for collision_id in get_slide_collision_count():
		var collision = get_slide_collision(collision_id)
		if collision.get_collider() is RigidBody3D:
			var push_dir = -collision.get_normal()
			#how much velocity the object needs to increase to match the player's velocity in the push direction
			var vel_diff_in_push_dir = velocity.dot(push_dir) - collision.get_collider().linear_velocity.dot(push_dir)
			#only count velocity towards push dir, aka away from the player
			vel_diff_in_push_dir = max(0, vel_diff_in_push_dir)
			#objects with more mass should be harder to push
			var mass_ratio = min(1, PHYSICS_MASS / collision.get_collider().mass)
			#dont push em from above/below
			push_dir.y = 0
			var push_force = mass_ratio * mass_ratio_multi
			collision.get_collider().apply_impulse(push_dir * vel_diff_in_push_dir * push_force, collision.get_position() - collision.get_collider().global_position)

func _physics_process(delta: float) -> void:
	if multiplayer_compatible and not is_multiplayer_authority():
		return

	var input_dir := Vector2.ZERO
	var direction := Vector3.ZERO
	if can_move:
		input_dir = Input.get_vector("left", "right", "forward", "backward")
		direction = (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if is_on_floor():
		
		if direction:
			velocity.x = lerp(velocity.x, direction.x * current_speed, delta * 5.0)
			velocity.z = lerp(velocity.z, direction.z * current_speed, delta * 5.0)
		else:
			velocity.x = move_toward(velocity.x, 0.0, current_speed)
			velocity.z = move_toward(velocity.z, 0.0, current_speed)

		if Input.is_action_just_pressed("jump"):
			velocity.y = jump_velocity
	else:
		if can_move:
			velocity += get_gravity() * delta
		
		var target_air_vel = platform_vel + (direction * current_speed)
		velocity.x = move_toward(velocity.x, target_air_vel.x, current_speed * delta * 5.0)
		velocity.z = move_toward(velocity.z, target_air_vel.z, current_speed * delta * 5.0)

	move_and_slide()
	if is_on_floor():
		platform_vel = get_platform_velocity()
	_rigidbody_interaction()
