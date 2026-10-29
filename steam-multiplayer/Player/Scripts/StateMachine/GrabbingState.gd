extends PlayerState

@export_subgroup("Interaction")
@export var interact_ray: RayCast3D
@export var hand: Marker3D

@export_subgroup("Weight Thresholds")
@export var light_threshold: float = 0.0
@export var average_threshold: float = 50
@export var heavy_threshold: float = 100

@export_subgroup("Pull Strength")
@export var light_pull_strength: float = 3000.0
@export var medium_pull_strength: float = 2000.0
@export var heavy_pull_strength: float = 1000.0
var current_pull_strength: float = light_pull_strength

@export var damping: float = 256.0

var is_grabbing_toggleable: bool = false
var grabbed_object: RigidBody3D = null

func _unhandled_input(event: InputEvent) -> void:
	if not is_grabbing_toggleable:
		if Input.is_action_just_pressed("grab"):
			_grab()
		elif Input.is_action_just_released("grab"):
			_drop()
	
	elif is_grabbing_toggleable:
		if Input.is_action_just_pressed("grab"):
			if grabbed_object == null:
				_grab()
			else:
				_drop()
	
	
	if Input.is_action_just_pressed("interact"):
		is_grabbing_toggleable = not is_grabbing_toggleable

func _process(delta: float) -> void:
	if grabbed_object != null:
		_pull_object()

func _grab():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		if collider is Package:
			if collider.is_grabbed == false:
				grabbed_object = collider
				grabbed_object.manage_package_authority.rpc(int(player.name), true)

func _drop():
	if grabbed_object != null:
		grabbed_object.manage_package_authority.rpc(1, false)
		grabbed_object = null

func _pull_object():
	var dir = hand.global_position - grabbed_object.global_position
	var pull_force = (dir * current_pull_strength) - (grabbed_object.linear_velocity * damping)
	grabbed_object.apply_central_force(pull_force)
