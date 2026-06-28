class_name CarData extends Resource

@export var model: String
@export var sprite: Resource

@export_category("Basics")
@export var mass: float:
	get: return mass
@export var wheelBase: int:
	get: return wheelBase
@export var brakePower: int:
	get: return brakePower

@export_category("Steering")
@export var baseSteeringPower: int
@export var steeringFloor: float
#Speed to switch from low speed grip to high speed grip
@export var gripCutoff: float
#Zero to One
@export var lowSpeedGrip:float
#Zero to One
@export var highSpeedGrip: float

@export_category("Drag and Friction")
#should be a small number (percent)
@export var drag: float:
	get: return drag
@export var baseFriction: float:
	get: return baseFriction

@export_category("Low Gear")
@export var lowGearMinPower: int
@export var lowGearEnginePower: int
@export var lowGearCurve: Curve

@export_category("Mid Gear")
@export var midGearMinPower: int
@export var midGearEnginePower: int
@export var midGearCurve: Curve

@export_category("High Gear")
@export var highGearMinPower: int
@export var highGearEnginePower: int
@export var highGearCurve: Curve

const MAX_SPEED = 1000.0

func get_engine_power(currentGear: PlayerCarController.GEAR, speed: float):
	match currentGear:
		PlayerCarController.GEAR.LOW:
			return max(lowGearEnginePower * lowGearCurve.sample(speed / MAX_SPEED), lowGearMinPower)
		PlayerCarController.GEAR.MID:
			return max(midGearEnginePower * midGearCurve.sample(speed / MAX_SPEED), midGearMinPower)
		PlayerCarController.GEAR.HIGH:
			return max(highGearEnginePower * highGearCurve.sample(speed / MAX_SPEED), highGearMinPower)

func get_best_gear(speed: float):
	if lowGearEnginePower * lowGearCurve.sample(speed / MAX_SPEED) > midGearEnginePower * midGearCurve.sample(speed * MAX_SPEED):
		return PlayerCarController.GEAR.LOW
	elif midGearEnginePower * midGearCurve.sample(speed / MAX_SPEED) > highGearEnginePower * highGearCurve.sample(speed / MAX_SPEED):
		return PlayerCarController.GEAR.MID
	else:
		return PlayerCarController.GEAR.HIGH

func get_steering_power(speed: float):
	if speed > steeringFloor:
		return baseSteeringPower
	else:
		return baseSteeringPower * (speed / steeringFloor)

func get_tire_grip(speed: float):
	if speed > gripCutoff:
		return highSpeedGrip
	else:
		return lowSpeedGrip
	
