extends AnimatableBody3D

@onready var enter_area: Area3D = $Area3D
@onready var exit_area: Area3D = $"../StaticBody3D/Area3D"

@onready var ghost_room: StaticBody3D = $"../StaticBody3D"

var players: Array[CharacterBody3D]


func _ready() -> void:
	enter_area.body_entered.connect(_on_area_entered)
	exit_area.body_exited.connect(_on_area_exited)

func _on_area_entered(body: Node3D) -> void:
	print("body entered")
	
	if not players.has(body):
		players.append(body)
	
	#manage the separation between the visuals the logic part
	body.player_visuals.top_level = true
	
	#manage position
	var relative_pos: Vector3 = to_local(body.global_position)
	var ghost_world_pos: Vector3 = ghost_room.to_global(relative_pos)
	
	body.global_position = ghost_world_pos
	
func _on_area_exited(body: Node3D) -> void:
	if players.has(body):
		players.erase(body)
	
	body.global_position = body.player_visuals.global_position
	body.player_visuals.top_level = false

func _process(delta: float) -> void:
	for body in players:
		if is_instance_valid(body) and is_instance_valid(ghost_room):
			var local_pos: Vector3 = ghost_room.to_local(body.global_position)
			
			body.player_visuals.global_position = to_global(local_pos)
			body.player_visuals.global_basis = global_basis * body.global_basis
