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



@export_subgroup("Steering")
##Force that will rotate the airship when steering.
@export var yaw_torque: float
##Angle the rudder will rotate in degrees.
@export var rudder_angle: float = 30



@export_subgroup("Banking")
##Stiffness controls how aggressively the aircraft rolls into the bank.
@export var stiffness: float = 2000
##Damping stops the airship from rotating past the target angle.
@export var damping: float = 3000
##Angle the airship will rotate to when banking.
@export var target_tilt_angle: float
