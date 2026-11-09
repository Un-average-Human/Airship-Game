@icon("uid://dkaeqim7alm7m")
extends RigidBody3D
class_name Dirigible

@export_category("Airship Parts")
@export var gas_valve: Valve
@export var vent_valve: Valve

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
var adjustable_lift: float
var current_adjustable_lift: float
var current_lift: float = min_lift
var max_upward_thrust: float

@export_subgroup("Capacity")
@export var storage_area: Area3D
@export var max_capacity: float = 100.0
var current_capacity: float = 0.0

func _ready() -> void:
	max_upward_thrust = (max_lift - mass * 9.8) / 9.8
	adjustable_lift = max_lift - min_lift
	
	#signals
	storage_area.body_entered.connect(_entered_storage_area)
	storage_area.body_exited.connect(_exited_storage_area)



func _unhandled_input(_event: InputEvent) -> void:
	if not is_multiplayer_authority():
		return

func _physics_process(_delta: float) -> void:
	_manage_lift()

func _manage_lift():
	current_adjustable_lift = adjustable_lift * vent_valve.value
	current_lift = min_lift + (gas_valve.value * current_adjustable_lift)
	print("adjustable lift is: " + str(current_adjustable_lift * vent_valve.value) + "\n" + "current lift is: " + str(current_lift))
	apply_central_force(Vector3.UP * (current_lift))



#package weight stuff :money_mouth_face:
func _entered_storage_area(package: Node3D):
	print(package.name)
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
