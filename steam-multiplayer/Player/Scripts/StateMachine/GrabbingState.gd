extends PlayerState

@export var interact_ray: RayCast3D
@export var hand: Marker3D
@export var pull_strength: float = 300.0
@export var damping: float = 256.0

var is_grabbing_toggleable: bool = false
var grabbed_object: RigidBody3D = null

func _unhandled_input(event: InputEvent) -> void:
	if is_grabbing_toggleable:
		if Input.is_action_just_pressed("grab"):
			if grabbed_object != null:
				grabbed_object = null
			else:
				_grab_manager()
#changed mass to 100kg (from 60kg)
func physics_update(delta: float) -> void:
	if not is_grabbing_toggleable:
		if Input.is_action_pressed("grab"):
			if grabbed_object == null:
				_grab_manager()
			else:
				_pull_object()
		else:
			grabbed_object = null
	else:
		if grabbed_object != null:
			_pull_object()

func _grab_manager():
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
		if collider.is_in_group("CanGrab"):
			print("grabbed")
			grabbed_object = collider

func _pull_object():
	var dir = hand.global_position - grabbed_object.global_position
	var pull_force = (dir * pull_strength) - (grabbed_object.linear_velocity * damping)
	grabbed_object.apply_central_force(pull_force)
