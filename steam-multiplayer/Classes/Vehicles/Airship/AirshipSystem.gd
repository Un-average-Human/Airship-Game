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

@export var sd: Resource

@export_subgroup("Lift")
@export var min_lift: float = 9700.0
@export var max_lift: float = 10000.0
@export var extra_lift = 50
var adjustable_lift: float
var current_adjustable_lift: float
var current_lift: float = min_lift
var max_upward_thrust: float

@export_subgroup("Capacity")
@export var storage_area: Area3D
@export var max_capacity: float = 200.0
var current_capacity: float = 0.0
var packages: Array[Package]
var players: Array[Player]

@export_subgroup("Steering")
@export var yaw_torque: float
@export var rudder_angle: float = 30

@export_subgroup("Banking")
##Stiffness controls how aggressively the aircraft rolls into the bank.
@export var stiffness: float = 2000
##Damping stops the airship from rotating past the target angle.
@export var damping: float = 3000
@export var target_tilt_angle: float = 30

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
	_manage_package_weight()

func _manage_lift():
	current_adjustable_lift = adjustable_lift * vent_valve.value
	current_lift = min_lift + (gas_valve.value * current_adjustable_lift)
	#print("adjustable lift is: " + str(current_adjustable_lift * vent_valve.value) + "\n" + "current lift is: " + str(current_lift))
	var weight_multi: float = max_upward_thrust / max_capacity
	var cargo_force: float = (current_capacity * weight_multi) * 9.8
	if current_capacity <= max_capacity:
		apply_central_force(Vector3.UP * ((extra_lift + current_lift) - cargo_force))
	else:
		apply_central_force(Vector3.UP * (current_lift - cargo_force))

func _steering():
	#banking
	var angle_diff: float = angle_difference(global_rotation.z, deg_to_rad(target_tilt_angle))
	var banking_torque: float = (angle_diff * stiffness) - (angular_velocity.z * damping)

func _manage_throttle():
	pass



#package weight stuff :money_mouth_face:
func _entered_storage_area(body: Node3D):
	print(body.name)
	if body is Package:
		packages.append(body)
	if body is Player:
		players.append(body)

func _exited_storage_area(body: Node3D):
	print(body.name)
	if body is Package:
		packages.erase(body)
	if body is Player:
		players.erase(body)

func _manage_package_weight():
	var total_weight = 0.0
	for package in packages:
		if package.get_colliding_bodies().size() >= 1 and not package.is_grabbed:
			total_weight += package.weight
	for player in players:
		total_weight += player.mass
	
	current_capacity = total_weight
	print(current_capacity)
