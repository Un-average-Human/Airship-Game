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
		#manage visuals
		var visuals: Node3D = body.visuals
		visuals.set_as_top_level(true)
		body.add_to_group("InGhostRoom")
		SignalBus.update_ghost_room_status.emit(body, visuals.is_set_as_top_level())
		
		#manage the player position
		var relative_pos: Vector3 = to_local(body.global_position)
		var ghost_world_pos: Vector3 = ghost_room.to_global(relative_pos)
		body.global_position = ghost_world_pos

func _exit_ghost_state(body: Node3D) -> void:
	if "visuals" in body:
		var visuals: Node3D = body.visuals
		#manage the player position
		body.global_position = visuals.global_position
		
		#manage visuals
		visuals.set_as_top_level(false)
		body.remove_from_group("InGhostRoom")
		SignalBus.update_ghost_room_status.emit(body, visuals.is_set_as_top_level())
		if body is Package:
			var relative_pos: Vector3 = ghost_room.to_local(body.global_position)
			var real_world_pos: Vector3 = to_global(relative_pos)
			body.global_position = real_world_pos

			
func _on_area_exited(body: Node3D) -> void:
	match body.get_script().get_global_name():
		"Player":
			_exit_ghost_state(body)
			players.erase(body)
		"Package":
			_exit_ghost_state(body)
			packages.erase(body)

func _process(delta: float) -> void:
	for body in enter_area.get_overlapping_bodies():
		if body is Package:
			if not body.is_grabbed and not packages.has(body):
				_enter_ghost_state(body)
				packages.append(body)
	for object: Node3D in packages + players:
		if is_instance_valid(object.visuals):
			var visuals: Node3D = object.visuals
			var local_pos: Vector3 = ghost_room.to_local(object.global_position)
			
			visuals.global_position = to_global(local_pos)
			visuals.global_basis = global_basis * object.global_basis
