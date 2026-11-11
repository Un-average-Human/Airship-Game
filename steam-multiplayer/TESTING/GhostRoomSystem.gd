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
	print("body entered")
	
	if body is CharacterBody3D:
		if not players.has(body):
			players.append(body)
	elif body is Package:
		if not packages.has(body):
			packages.append(body)
	
	#manage the separation between the visuals the logic part
	body.visuals.top_level = true
	
	#manage position
	var relative_pos: Vector3 = to_local(body.global_position)
	var ghost_world_pos: Vector3 = ghost_room.to_global(relative_pos)
	
	body.global_position = ghost_world_pos
	
func _on_area_exited(body: Node3D) -> void:
	if body is CharacterBody3D:
		if players.has(body):
			players.erase(body)
	elif body is Package:
		if packages.has(body):
			packages.erase(body)
	
	body.global_transform = body.visuals.global_transform
	body.visuals.top_level = false

func _process(delta: float) -> void:
	for body in players:
		if is_instance_valid(body) and is_instance_valid(ghost_room):
			var local_pos: Vector3 = ghost_room.to_local(body.global_position)
			
			body.visuals.global_position = to_global(local_pos)
			body.visuals.global_basis = global_basis * body.global_basis

	for package in packages:
		if is_instance_valid(package) and is_instance_valid(ghost_room):
			var local_pos: Vector3 = ghost_room.to_local(package.global_position)
			
			package.visuals.global_position = to_global(local_pos)
			package.visuals.global_basis = global_basis * package.global_basis
