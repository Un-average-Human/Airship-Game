extends AnimatableBody3D

@onready var enter_area: Area3D = $Area3D
@onready var exit_area: Area3D = $"../StaticBody3D/Area3D"

@onready var ghost_room: StaticBody3D = $"../StaticBody3D"


func _ready() -> void:
	enter_area.body_entered.connect(_on_area_entered)
	exit_area.body_exited.connect(_on_area_exited)

func _on_area_entered(body: Node3D) -> void:
	print("body entered")
	
	#manage the separation between the visuals the logic part
	body.player_visuals.top_level = true
	
	#manage position
	var relative_pos: Vector3 = to_local(body.global_position)
	var ghost_world_pos: Vector3 = ghost_room.to_global(relative_pos)
	
	body.global_position = ghost_world_pos
	
func _on_area_exited(body: Node3D) -> void:
	body.global_position = body.player_visuals.global_position
	body.player_visuals.top_level = false

func _process(delta: float) -> void:
	pass
