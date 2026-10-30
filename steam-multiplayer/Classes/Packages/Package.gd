@icon("uid://1c868vq5xjgb")
extends RigidBody3D
class_name Package

@export var stats_resource: PackageStats
@export var multiplayer_synchronizer: MultiplayerSynchronizer

var buy_price: float
var sell_price: float

var weight: float
var package_mesh: Mesh

@export var is_grabbed: bool = false 

func _ready() -> void:
	sell_price = stats_resource.sell_price
	buy_price = stats_resource.buy_price
	weight = stats_resource.weight
	package_mesh = stats_resource.package_mesh
	mass = weight

@rpc("any_peer", "call_local", "reliable")
func update_grab_state(grabbed: bool) -> void:
	if multiplayer.is_server():
		is_grabbed = grabbed
