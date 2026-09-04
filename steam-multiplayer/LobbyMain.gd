extends Node3D

@export var spawn_point: Node3D
const PLAYER_CONTROLLER = preload("uid://bxrtwet2knbel")
var players: Array[CharacterBody3D]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Networking.host_created.connect(on_host_created)
	multiplayer.peer_disconnected.connect(remove_peer)

func on_host_created() -> void:
	#spawns the server player
	spawn_player(multiplayer.get_unique_id())
	
	if multiplayer.is_server():
		multiplayer.peer_connected.connect(on_peer_connected)

func on_peer_connected(peer_id: int) -> void:
	spawn_player(peer_id)

#if a player quits the game it'll delete their player character
func remove_peer(peer_id: int):
	for player in players:
		if player.name == str(peer_id):
			player.queue_free()

#creates a new player and adds it to the scene
func spawn_player(peer_id: int) -> void:
	var new_player := PLAYER_CONTROLLER.instantiate() as CharacterBody3D
	new_player.name = str(peer_id)
	add_child(new_player)
	initialize_player(new_player)

func initialize_player(player: CharacterBody3D) -> void:
	player.position = spawn_point.global_position
	for other_players in players:
		player.add_collision_exception_with(other_players)
	players.append(player)


#what to do after clicking the host
func _on_host_button_pressed() -> void:
	Networking.host_lobby()


func _on_multiplayer_spawner_spawned(node: Node) -> void:
	if node is CharacterBody3D:
		initialize_player(node)
