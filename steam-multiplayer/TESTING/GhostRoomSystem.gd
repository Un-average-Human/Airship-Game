extends AnimatableBody3D

@onready var enter_area: Area3D = $Area3D
@onready var exit_area: Area3D = $"../StaticBody3D/Area3D"

@onready var ghost_room: StaticBody3D = $"../StaticBody3D"

var players: Array[CharacterBody3D]
var packages: Array[Package]

func _ready() -> void:
	enter_area.body_entered.connect(_on_area_entered)
	exit_area.body_exited.connect(_on_area_exited)

func _on_area_entered(body: Node3D) -> void:
	if "visuals" in body:
		var visuals: Node3D = body.visuals
		var visuals_copy = visuals.duplicate()
		visuals_copy.top_level = true

func _on_area_exited(body: Node3D) -> void:
	pass

func _process(delta: float) -> void:
	pass
