@icon("uid://1c868vq5xjgb")
extends RigidBody3D
class_name Package

@export var stats_resource: PackageStats
@export var visuals: Node3D
@export var multiplayer_synchronizer: MultiplayerSynchronizer

var buy_price: float
var sell_price: float

var weight: float
var package_mesh: Mesh

@export var is_grabbed: bool = false 
@export var holder: NodePath = ""

func _ready() -> void:
	if not multiplayer.is_server():
		set_freeze_enabled(true)
		set_freeze_mode(RigidBody3D.FREEZE_MODE_KINEMATIC)
	
	sell_price = stats_resource.sell_price
	buy_price = stats_resource.buy_price
	weight = stats_resource.weight
	package_mesh = stats_resource.package_mesh
	mass = weight
