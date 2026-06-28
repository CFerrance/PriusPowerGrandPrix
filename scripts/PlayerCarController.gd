class_name PlayerCarController extends Car

@export var quickTimeLimit: float = 5.0
@export var incorrectPenalty: float = 3.5
@export var overTimePenalty: float = 2.0

@onready var remoteTransform = $RemoteTransform2D

enum INPUT_STATES {DISABLED, REVVING, DRIVING, PIT_LANE}
var currentInputState : INPUT_STATES

enum GEAR{LOW, MID, HIGH}
var currentGear: GEAR
signal gearChange(newGear)

var QTEs : Array[String] = ["QuickTimeOne", "QuickTimeTwo", "QuickTimeThree", "QuickTimeFour"]
var currentQTEs: Array[String]
var successes := 0


func _ready():
	super()
	currentGear = GEAR.LOW
	currentInputState = INPUT_STATES.DISABLED

func _physics_process(delta):
	match currentInputState:
		INPUT_STATES.DRIVING:
			_handle_shifting()
			_calculate_steering()
			_handle_acceleration()
	_apply_friction()

#region Driving Controls
func _handle_shifting():
	if Input.is_action_just_pressed("Upshift"):
		if currentGear != GEAR.HIGH:
			currentGear += 1
			gearChange.emit(currentGear)
	elif Input.is_action_just_pressed("Downshift"):
		if currentGear != GEAR.LOW:
			currentGear -= 1
			gearChange.emit(currentGear)

func _calculate_steering():
	var sideways = transform.x
	var steeringPower = carData.get_steering_power(get_speed())
	var steering = Input.get_axis("TurnLeft", "TurnRight") * steeringPower
	
	apply_torque(steering)
	
	var turnDot = linear_velocity.dot(sideways)
	var tireGrip = -1 * carData.get_tire_grip(get_speed())
	apply_central_force(sideways * turnDot * tireGrip)

func _handle_acceleration():
	var forwards = -transform.y
	var acceleration:  Vector2
	if Input.is_action_pressed("Brake"):
		acceleration = -forwards * carData.brakePower
	elif Input.is_action_pressed("Accelerate"):
		acceleration = forwards * carData.get_engine_power(currentGear, get_speed())
	apply_central_force(acceleration)

func _apply_friction():
	if get_speed() < 5:
		linear_velocity = Vector2.ZERO
	var frictionForce = linear_velocity * -1 * carData.baseFriction
	var dragForce = linear_velocity * linear_velocity.length() * -1 * carData.drag
	apply_central_force(frictionForce + dragForce)

#endregion

#region Pit Lane
func on_pit_entry():
	super()
	generate_quick_time_sequence()

func generate_quick_time_sequence():
	var rng = RandomNumberGenerator.new()
	currentQTEs = [QTEs[rng.randi_range(0, len(QTEs) - 1)]]
	successes = 0
	print("TODO: DISPLAY QTE BUTTONS")

func _unhandled_input(event):
	if currentInputState == INPUT_STATES.PIT_LANE and not currentQTEs.is_empty():
		if event.is_action(currentQTEs[successes]):
			successes += 1
			if successes == len(currentQTEs):
				print("passed QTE")
				currentQTEs = []
		else:
			print("failed QTE")

#endregion

func attach_camera(cam: Camera2D):
	remoteTransform.remote_path = cam.get_path()

func get_speed():
	return linear_velocity.length()

func set_input_state(state: INPUT_STATES):
	currentInputState = state

func on_race_completed():
	super()
	set_input_state(INPUT_STATES.DISABLED)
