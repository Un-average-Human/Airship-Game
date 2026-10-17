extends CharacterBody3D

#camera
@export var neck: Node3D
@export var player_cam: Camera3D
@export var interact_raycast: RayCast3D

#multiplayer
@export var multiplayer_compatible: bool 

#stats
@export var walking_speed: float = 5.0
@export var running_speed: float = 8.0
const JUMP_VELOCITY = 4.0


func _enter_tree() -> void:
	if multiplayer_compatible:
		set_multiplayer_authority(name.to_int())

func _ready() -> void:
	if multiplayer_compatible and is_multiplayer_authority():
		player_cam.make_current()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event: InputEvent) -> void:
	if multiplayer_compatible:
		if not is_multiplayer_authority():
			return
	
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		neck.rotate_x(-event.relative.y * 0.005)
		neck.rotation.x = clamp(neck.rotation.x, deg_to_rad(-70), deg_to_rad(70))
	
	if Input.is_action_just_pressed("interact"):
		if interact_raycast.is_colliding():
			var collider = interact_raycast.get_collider()
			if collider.is_in_group("interactable"):
				print("function should be called")
				collider.execute(self)
