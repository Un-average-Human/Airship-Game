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
@export var max_capacity: int = 100
@export var max_speed: float = 5.0

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	apply_central_force(Vector3.UP * max_lift)
