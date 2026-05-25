class_name PlayerCarController extends Car

@onready var remoteTransform = $RemoteTransform2D

enum INPUT_STATES {DISABLED, REVVING, DRIVING, PIT_LANE}
var currentInputState : INPUT_STATES

enum GEAR{LOW, MID, HIGH}
var currentGear: GEAR
signal gearChange(newGear)

var steeringDirection: float
var acceleration = Vector2.ZERO

func _ready():
	super()
	currentGear = GEAR.LOW
	currentInputState = INPUT_STATES.DISABLED

func attach_camera(cam: Camera2D):
	remoteTransform.remote_path = cam.get_path()

func get_speed():
	return velocity.length()

func set_input_state(state: INPUT_STATES):
	currentInputState = state

func on_race_completed():
	super()
	set_input_state(INPUT_STATES.DISABLED)

func _physics_process(delta):
	match currentInputState:
		INPUT_STATES.DRIVING:
			acceleration = Vector2.ZERO
			_get_input()
			_apply_friction()
			_calculate_steering(delta)
			velocity -= acceleration * delta
			move_and_slide()

func _apply_friction():
	if velocity.length() < 5:
		velocity = Vector2.ZERO
	var frictionForce = velocity * _get_friction()
	var dragForce = velocity * velocity.length() * carData.drag
	acceleration -= frictionForce + dragForce

func _get_input():
	steeringDirection = -1 * Input.get_axis("TurnLeft", "TurnRight") * deg_to_rad(carData.get_max_steering_angle(velocity.length()))
	
	if Input.is_action_pressed("Accelerate"):
		acceleration = transform.y * carData.get_engine_power(currentGear, velocity.length())
	if Input.is_action_pressed("Brake"):
		acceleration = -transform.y * carData.brakePower
	
	if Input.is_action_just_pressed("Upshift"):
		_shift(1)
	elif Input.is_action_just_pressed("Downshift"):
		_shift(-1)

func _shift(dir):
	if dir == 1 and currentGear != GEAR.HIGH:
		currentGear += 1
		gearChange.emit(currentGear)
	elif dir == -1 and currentGear != GEAR.LOW:
		currentGear -= 1
		gearChange.emit(currentGear)

func _calculate_steering(delta):
	var wheelBase = carData.wheelBase / 2.0
	var rearWheel = position - transform.y * wheelBase
	var frontWheel = position + transform.y * wheelBase
	rearWheel += velocity * delta
	frontWheel += velocity.rotated(steeringDirection) * delta
	var heading = (frontWheel - rearWheel).normalized()
	velocity = -heading * velocity.length()
	rotation_degrees = rad_to_deg(heading.angle()) - 90.0

func _get_friction():
	return -0.8
