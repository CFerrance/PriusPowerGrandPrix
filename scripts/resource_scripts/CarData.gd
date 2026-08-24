class_name CarData extends Resource

#exports
@export var model: String
@export var sprite: Resource

@export_category("Basics")
@export var mass: float
@export var brake_power: int
@export var reverse_power: int

@export_category("Steering")
@export var base_steering_power: int
@export var steering_floor: float
#Speed to switch from low speed grip to high speed grip
@export var low_speed_grip_cutoff: float
@export var mid_speed_grip_cutoff: float
@export var low_speed_grip:float
@export var mid_speed_grip:float
@export var high_speed_grip: float

@export_category("Drag and Friction")
#should be a small number (percent)
@export var drag: float:
	get: return drag
@export var base_friction: float:
	get: return base_friction

@export_category("Low Gear")
@export var low_gear_min_power: int
@export var low_gear_engine_power: int
@export var low_gear_curve: Curve

@export_category("Mid Gear")
@export var mid_gear_min_power: int
@export var mid_gear_engine_power: int
@export var mid_gear_curve: Curve

@export_category("High Gear")
@export var high_gear_min_power: int
@export var high_gear_engine_power: int
@export var high_gear_curve: Curve

#constants
const MAX_SPEED: float = 1000.0


func get_engine_power(current_gear: PlayerCarController.Gear, speed: float) -> float:
	if current_gear == PlayerCarController.Gear.HIGH:
		return max(high_gear_engine_power * high_gear_curve.sample(clampf((speed / MAX_SPEED), 0.0, 1.0)), high_gear_min_power)
	elif current_gear == PlayerCarController.Gear.MID:
		return max(mid_gear_engine_power * mid_gear_curve.sample(clampf((speed / MAX_SPEED), 0.0, 1.0)), mid_gear_min_power)
	else :
		assert(current_gear == PlayerCarController.Gear.LOW)
		return max(low_gear_engine_power * low_gear_curve.sample(clampf((speed / MAX_SPEED), 0.0, 1.0)), low_gear_min_power)


func get_best_gear(speed: float) -> PlayerCarController.Gear:
	if (low_gear_engine_power * low_gear_curve.sample(speed / MAX_SPEED) 
			> mid_gear_engine_power * mid_gear_curve.sample(speed * MAX_SPEED)):
		return PlayerCarController.Gear.LOW
	elif (mid_gear_engine_power * mid_gear_curve.sample(speed / MAX_SPEED) 
			> high_gear_engine_power * high_gear_curve.sample(speed / MAX_SPEED)):
		return PlayerCarController.Gear.MID
	else:
		return PlayerCarController.Gear.HIGH


func get_steering_power(speed: float) -> float:
	if speed > steering_floor:
		return base_steering_power
	else:
		#don't turn as much at low speed
		return (speed / steering_floor) * base_steering_power


func get_tire_grip(speed: float) -> float:
	if speed > mid_speed_grip_cutoff:
		return high_speed_grip
	elif speed > low_speed_grip_cutoff:
		return mid_speed_grip
	else:
		return low_speed_grip
	
