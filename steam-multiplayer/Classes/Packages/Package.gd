@icon("uid://1c868vq5xjgb")
extends RigidBody3D
class_name Package

@export var stats_resource: PackageStats

var buy_price: float
var sell_price: float

var weight: float
var package_mesh: Mesh

func _ready() -> void:
	#price stats
	sell_price = stats_resource.sell_price
	buy_price = stats_resource.buy_price
	
	#physical stats
	weight = stats_resource.weight
	package_mesh = stats_resource.package_mesh
