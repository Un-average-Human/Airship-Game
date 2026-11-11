extends AnimatableBody3D

@onready var area_3d: Area3D = $Area3D
@onready var ghost_room: StaticBody3D = $"../StaticBody3D"


func _ready() -> void:
	area_3d.body_entered.connect(_on_area_entered)
	area_3d.body_exited.connect(_on_area_exited)

func _on_area_entered(body: Node3D) -> void:
	print("body entered")
	
	var relative_pos: Vector3 = to_local(body.global_position)
	var ghost_world_pos: Vector3 = ghost_room.to_global(relative_pos)
	
	body.global_position = ghost_world_pos
	
func _on_area_exited(body: Node3D) -> void:
	print("body exited")
