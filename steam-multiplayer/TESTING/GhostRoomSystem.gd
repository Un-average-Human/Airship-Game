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
		match body.get_script().get_global_name():
			"Player":
				_enter_ghost_state(body)
				players.append(body)
			"Package":
				if not body.is_grabbed:
					_enter_ghost_state(body)
					packages.append(body)

func _enter_ghost_state(body: Node3D) -> void:
	if "visuals" in body:
		#manage the copy
		var visuals: Node3D = body.visuals
		var visuals_copy = visuals.duplicate()
		visuals_copy.name = "VisualsCopy"
		body.add_child(visuals_copy)
		visuals_copy.top_level = true
		
		#manage the player position
		var relative_pos: Vector3 = to_local(body.global_position)
		var ghost_world_pos: Vector3 = ghost_room.to_global(relative_pos)
		body.global_position = ghost_world_pos

func _exit_ghost_state(body: Node3D) -> void:
	if body.get_node("VisualsCopy"):
		var visuals_copy: Node3D = body.get_node("VisualsCopy")
		#manage the player position
		body.global_position = visuals_copy.global_position
		
		#manage the copy
		visuals_copy.queue_free()

func _on_area_exited(body: Node3D) -> void:
		match body.get_script().get_global_name():
			"Player":
				_exit_ghost_state(body)
				players.erase(body)
			"Package":
				if not body.is_grabbed:
					_exit_ghost_state(body)
					packages.erase(body)

func _process(delta: float) -> void:
	for object: Node3D in packages + players:
		if is_instance_valid(object.get_node("VisualsCopy")):
			var visual_copy: Node3D = object.get_node("VisualsCopy")
			var local_pos: Vector3 = ghost_room.to_local(object.global_position)
			
			visual_copy.global_position = to_global(local_pos)
			visual_copy.global_basis = global_basis * object.global_basis
