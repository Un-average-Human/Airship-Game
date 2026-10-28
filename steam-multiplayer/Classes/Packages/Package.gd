@icon("uid://1c868vq5xjgb")
extends RigidBody3D
class_name Package

@export var stats_resource: PackageStats
@export var multiplayer_synchronizer: MultiplayerSynchronizer

var buy_price: float
var sell_price: float

var weight: float
var package_mesh: Mesh

func _ready() -> void:
	sell_price = stats_resource.sell_price
	buy_price = stats_resource.buy_price
	weight = stats_resource.weight
	package_mesh = stats_resource.package_mesh
	mass = weight

#manages the multiplayer authority, allowing it to properly synchronise 
@rpc("any_peer", "call_local", "reliable")
func manage_package_authority(new_authority_id: int) -> void:
	set_multiplayer_authority(new_authority_id)
	if multiplayer_synchronizer:
		multiplayer_synchronizer.set_multiplayer_authority(new_authority_id)
	
	if new_authority_id == multiplayer.get_unique_id():
		freeze = false
	else:
		freeze = true
		freeze_mode = RigidBody3D.FREEZE_MODE_KINEMATIC
