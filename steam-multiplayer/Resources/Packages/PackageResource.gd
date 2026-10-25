extends Resource
class_name PackageStats

@export_enum(
"COFFEE", 
"STEEL", 
"WOOD", 
"MILK",

#high-risk high-reward
"ATOMIC_BOMB", 
"CROCODILE",
"GLASS"
) var package_type

@export var weight: float
@export var package_mesh: Mesh
