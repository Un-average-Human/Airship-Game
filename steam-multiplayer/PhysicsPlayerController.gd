extends RigidBody3D

@export_subgroup("Movement/Ground")
@export var floor_cast: RayCast3D
@export var jump_velocity: float = 4

var is_grounded: bool

func _enter_tree() -> void:
	set_multiplayer_authority(name.to_int())

func _physics_process(delta: float) -> void:
	is_grounded = floor_cast.is_colliding()

	if Input.is_action_just_pressed("jump") and is_grounded:
		apply_central_impulse(Vector3.UP * jump_velocity)
