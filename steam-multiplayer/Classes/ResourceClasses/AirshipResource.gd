extends Resource
class_name AirshipStats

@export_subgroup("Lift")
##Minimum lift that can be applied to the airship. This has to be BELOW the force pushing it downwards. 
##You can calculate said force by doing mass * gravity.
@export var min_lift: float = 9700
##Maximum lift that can be applied to the airship. This has to be ABOVE the force pushing it downwards.
##You can calculate said force by doing mass * gravity.
@export var max_lift: float = 10000
##The extra lift that will be applied so the airship will still be able to lift when it reaches its 
##maximum capacity.
@export var extra_lift = 50



@export_subgroup("Capacity and Weight")
##Maximum capacity dictates how much weight your airship can carry in kilograms.
@export var max_capacity: float = 200.0
##The airship's mass.
@export var airship_mass: float
