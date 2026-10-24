extends Node

@export var interact_ray: RayCast3D

var is_grabbing_toggleable: bool = false
var grabbed_object: RigidBody3D = null

func _unhandled_input(event: InputEvent) -> void:
	if is_grabbing_toggleable:
		if Input.is_action_just_pressed("interact"):
			pass

func _physics_update(delta: float) -> void:
	if not is_grabbing_toggleable:
		if Input.is_action_pressed("interact"):
			pass
	
	if interact_ray.is_colliding():
		var collider = interact_ray.get_collider()
