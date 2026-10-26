@icon("uid://dkaeqim7alm7m")
extends RigidBody3D
class_name Dirigible

@export_category("Airship Parts")

@export_subgroup("Aerodynamic Components")
@export var rudder: Node3D

@export_subgroup("Mechanical Components")
@export var propeller: Node3D
@export var helm: Node3D
@export var helm_angle: float = 360



@export_category("Stats")

@export_subgroup("Lift")
@export var min_lift: float = 9700
@export var max_lift: float = 9900
var current_lift = min_lift
var max_upward_thrust

@export_subgroup("Capacity")
@export var storage_area: Area3D
@export var max_capacity: float = 100.0
var current_capacity: float = 90.0

func _ready() -> void:
	max_upward_thrust = max_lift - (mass * 9.8)

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_Q) and current_lift < max_lift:
		current_lift += 40
		print(current_lift)
	if Input.is_key_pressed(KEY_E) and current_lift > min_lift:
		current_lift -= 40
		print(current_lift)

func _physics_process(delta: float) -> void:
	apply_central_force(Vector3.UP * (current_lift))

func _entered_storage_area(package: Node3D):
	if package is not RigidBody3D:
		return
	current_capacity += package.mass
	if current_capacity <= max_capacity:
		var weight_multi: float = max_upward_thrust / max_capacity
		package.mass *= weight_multi
