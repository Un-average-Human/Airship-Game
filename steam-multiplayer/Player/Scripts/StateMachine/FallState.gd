extends PlayerState

@onready var state_machine = get_parent()

func physics_update(delta: float) -> void:
	if not player.is_multiplayer_authority():
		return

	var input_dir := Input.get_vector("left", "right", "forward", "backward")
	var direction := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		player.velocity.x = direction.x * player.walking_speed
		player.velocity.z = direction.z * player.walking_speed
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.walking_speed)
		player.velocity.z = move_toward(player.velocity.z, 0, player.walking_speed)
		
	player.velocity += player.get_gravity() * delta
	player.move_and_slide()
	
	if player.is_on_floor():
		state_machine.change_state("floor")
