extends CharacterBody3D

# Camera
@export_subgroup("Camera")
@export var neck: Node3D
@export var player_cam: Camera3D
@export var interact_raycast: RayCast3D

# Interaction
@export_subgroup("Interaction")
@export var interact_ray: RayCast3D

# Multiplayer
@export_subgroup("Multiplayer")
@export var multiplayer_compatible: bool

# Movement
@export_subgroup("Movement")
@export var walking_speed: float = 5.0
@export var running_speed: float = 8.0
@export var jump_velocity: float = 4.0
var current_speed = walking_speed

func _enter_tree() -> void:
	if multiplayer_compatible:
		set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if multiplayer_compatible and is_multiplayer_authority():
		player_cam.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if multiplayer_compatible and not is_multiplayer_authority():
		return

	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		neck.rotate_x(-event.relative.y * 0.005)
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-70), deg_to_rad(70))

	if event.is_action_pressed("interact") and not event.is_echo():
		if interact_raycast.is_colliding():
			var collider := interact_raycast.get_collider()
			if collider.is_in_group("interactable"):
				collider.execute(self)

func _physics_process(delta: float) -> void:
	if multiplayer_compatible and not is_multiplayer_authority():
		return

	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0.0, walking_speed)
		velocity.z = move_toward(velocity.z, 0.0, walking_speed)

	move_and_slide()
