extends RigidBody3D
#class_name Player

@export_subgroup("Multiplayer")
@export var multiplayer_compatible: bool = true

@export_subgroup("Movement/Camera")
@export var camera: Camera3D
@export var head: Marker3D
@export var neck: Marker3D
@export var interact_raycast: RayCast3D
var is_camera_locked: bool = false

@export_subgroup("Movement/Ground")
@export var floor_cast: RayCast3D
@export var jump_velocity: float = 4.0
@export var speed: float = 5.0
@export var acceleration: float = 40.0
var can_move: bool = true

var is_grounded: bool

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
		head.rotate_y(-event.relative.x * 0.005)
		neck.rotate_x(-event.relative.y * 0.005)
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-70), deg_to_rad(70))

	if event.is_action_pressed("interact"):
		if interact_raycast.is_colliding():
			var collider := interact_raycast.get_collider()
			if collider.is_in_group("interactable"):
				collider.execute(self)

func _physics_process(_delta: float) -> void:
	is_grounded = floor_cast.is_colliding()

	if Input.is_action_just_pressed("jump") and is_grounded:
		apply_central_impulse(Vector3.UP * jump_velocity * mass)
		
	var direction := Vector3.ZERO
	if can_move:
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		direction = (head.global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()


	var target_vel := direction * speed
	var vel_diff := target_vel - linear_velocity
	vel_diff.y = 0.0
	
	apply_central_force(vel_diff * acceleration * mass)
