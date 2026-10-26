extends Resource
class_name PackageStats

@export_enum(
"TEST",
"COFFEE", 
"STEEL", 
"WOOD", 
"MILK",

#high-risk high-reward
"ATOMIC_BOMB", 
"CROCODILE",
"GLASS"
) var package_type

@export_subgroup("Price")
@export var sell_price: float
@export var buy_price: float

@export_subgroup("Physical")
@export var weight: float
@export var package_mesh: Mesh
