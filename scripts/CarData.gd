class_name CarData extends Resource

@export var model: String
@export var sprite: Resource

@export_category("Base Controls")
@export var wheelBase: int:
	get: return wheelBase
@export var brakePower: int:
	get: return brakePower
@export var grip: int:
	get: return grip

@export_category("Steering")
#how sharply the car can turn
@export var steeringAngle: int: 
	get: return steeringAngle
#how much traction the car has at low speeds
@export var maxTraction: float:
	get: return maxTraction
#how fast the car can go before incurring a turn penalty
@export var noPenaltyMax: float:
	get: return noPenaltyMax
#A curve for traction penalties at speeds over NoPenaltyMax
@export var tractionPenalty: Curve

@export_category("Drag and Friction")
#should be a small, negative number (percent)
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

func get_engine_power(currentGear, speed):
	match currentGear:
		PlayerCarController.GEAR.LOW:
			return max(lowGearEnginePower * lowGearCurve.sample(speed / MAX_SPEED), lowGearMinPower)
		PlayerCarController.GEAR.MID:
			return max(midGearEnginePower * midGearCurve.sample(speed / MAX_SPEED), midGearMinPower)
		PlayerCarController.GEAR.HIGH:
			return max(highGearEnginePower * highGearCurve.sample(speed / MAX_SPEED), highGearMinPower)


func get_traction(speed):
	if speed <= noPenaltyMax:
		return maxTraction
	else:
		return tractionPenalty.sample(speed / MAX_SPEED) * maxTraction


func get_best_gear(speed):
	if lowGearEnginePower * lowGearCurve.sample(speed / MAX_SPEED) > midGearEnginePower * midGearCurve.sample(speed * MAX_SPEED):
		return PlayerCarController.GEAR.LOW
	elif midGearEnginePower * midGearCurve.sample(speed / MAX_SPEED) > highGearEnginePower * highGearCurve.sample(speed / MAX_SPEED):
		return PlayerCarController.GEAR.MID
	else:
		return PlayerCarController.GEAR.HIGH
