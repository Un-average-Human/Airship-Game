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
var current_capacity: float = 0.0

func _ready() -> void:
	max_upward_thrust = (max_lift - mass * 9.8) / 9.8
	storage_area.body_entered.connect(_entered_storage_area)
	storage_area.body_exited.connect(_exited_storage_area)

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
	print(package)
	if package is not Package:
		return
	var weight_multi: float = max_upward_thrust / max_capacity
	print("max upwards thrust: " + str(max_upward_thrust) + "\n" + "weight multi: " + str(weight_multi))
	var new_weight = package.mass * weight_multi
	package.mass = new_weight
	print("weight is: " + str(package.mass) + " It should be: " + str(new_weight))

func _exited_storage_area(package: Node3D):
	print(package)
	if package is not Package:
		return
		
	package.mass = package.weight
