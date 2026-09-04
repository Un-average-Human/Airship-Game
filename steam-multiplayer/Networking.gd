extends Node

signal host_created()

#lobby settings
var lobby_type = Steam.LobbyType.LOBBY_TYPE_FRIENDS_ONLY
const MAX_MEMBERS: int = 4

var peer: SteamMultiplayerPeer

func _ready():
	#relay network that allows players to connect to the host's system while removing certain security risks.
	#this line of code simply initialises the relay network
	Steam.initRelayNetworkAccess()
	
	#connect the lobby_created and lobby_joined signals to their respective functions
	Steam.lobby_created.connect(on_lobby_created)
	Steam.lobby_joined.connect(on_lobby_joined)
	Steam.join_requested.connect(on_join_requested)

func host_lobby() -> void:
	#lobby_created and lobby_joined signals will emit
	Steam.createLobby(lobby_type, MAX_MEMBERS)


#called after creating a lobby
func on_lobby_created(connect: int, lobby_id: int) -> void:
	#make the responsible for creating the lobby a host
	if connect == Steam.RESULT_OK:
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_host()
		multiplayer.multiplayer_peer = peer
		host_created.emit()

#called when joining a lobby, including after creating one
func on_lobby_joined(lobby_id: int, permissions: int, locked: bool, response: int) -> void:
	if response == Steam.CHAT_ROOM_ENTER_RESPONSE_SUCCESS:
		#ignore if we created the lobby
		if Steam.getLobbyOwner(lobby_id) == Steam.getSteamID():
			return
		peer = SteamMultiplayerPeer.new()
		peer.server_relay = true
		peer.create_client(Steam.getLobbyOwner(lobby_id))
		multiplayer.multiplayer_peer = peer


#will be called when trying to join from the steam interface
func on_join_requested(lobby_id: int, steam_id: int) -> void:
	#will emit the lobby_joined signal
	Steam.joinLobby(lobby_id)

func _process(delta: float) -> void:
	Steam.run_callbacks()
