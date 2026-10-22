extends RigidBody3D

@export_category("Airship Parts")

@export_subgroup("Aerodynamic Components")
@export var rudder: Node3D

@export_subgroup("Mechanical Components")
@export var propeller: Node3D
@export var helm: Node3D
@export var helm_angle: float = 360



@export_category("Stats")

@export var min_lift: float = 9700
@export var max_lift: float = 9900
@export var max_capacity: float = 100.0
var current_capacity: float = 90.0
var current_lift = min_lift
var max_upward_thrust

func _ready() -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_key_pressed(KEY_Q) and current_lift < max_lift:
		current_lift += 40
		print(current_lift)
	if Input.is_key_pressed(KEY_E) and current_lift > min_lift:
		current_lift -= 40
		print(current_lift)

func _physics_process(delta: float) -> void:
	apply_central_force(Vector3.UP * (current_lift))
