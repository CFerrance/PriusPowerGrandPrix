class_name PlayerCarController extends Car

#signals
signal gear_changed

#enums
enum InputState {
	DISABLED, 
	REVVING, 
	DRIVING, 
	PIT_LANE,
}

enum Gear {
	LOW, 
	MID, 
	HIGH,
}

#exports
@export_category("Quick Time Events")
@export var qte_time_limit: float = 5.0
@export var incorrect_penalty: float = 3.5
@export var too_slow_penalty: float = 2.0
@export_category("Other")
@export var remote_transform: RemoteTransform2D

#variables
var current_input_state : InputState
var current_gear: Gear
var current_qtes: Array[String]
var successes: int
var player_cam: Camera2D

#constants
const QTEs : Array[String] = ["QuickTimeOne", "QuickTimeTwo", "QuickTimeThree", "QuickTimeFour"]


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	match current_input_state:
		InputState.DRIVING:
			_handle_shifting()
			_calculate_steering()
			_handle_acceleration()
	_apply_friction()

#region Driving Controls
func _handle_shifting() -> void:
	if Input.is_action_just_pressed("Upshift"):
		if current_gear != Gear.HIGH:
			current_gear = (current_gear + 1) as Gear
			gear_changed.emit(current_gear)
	elif Input.is_action_just_pressed("Downshift"):
		if current_gear != Gear.LOW:
			current_gear = (current_gear - 1) as Gear
			gear_changed.emit(current_gear)


func _calculate_steering() -> void:
	var sideways: Vector2 = transform.x
	var steering_power: float = car_data.get_steering_power(get_speed())
	var steering: float = Input.get_axis("TurnLeft", "TurnRight") * steering_power
	
	apply_torque(steering)
	
	var turn_dot: float = linear_velocity.dot(sideways)
	var tire_grip: float = -1 * car_data.get_tire_grip(get_speed())
	apply_central_force(sideways * turn_dot * tire_grip)


func _handle_acceleration() -> void:
	var forwards: Vector2 = -transform.y
	var acceleration:  Vector2
	if Input.is_action_pressed("Brake"):
		acceleration = -forwards * car_data.brake_power
	elif Input.is_action_pressed("Accelerate"):
		acceleration = forwards * car_data.get_engine_power(current_gear, get_speed())
	apply_central_force(acceleration)

func _apply_friction() -> void:
	if get_speed() < 5:
		linear_velocity = Vector2.ZERO
	var friction_force: Vector2 = linear_velocity * -1 * car_data.base_friction
	var drag_force: Vector2 = linear_velocity * linear_velocity.length() * -1 * car_data.drag
	apply_central_force(friction_force + drag_force)

#endregion

#region Pit Lane
func on_pit_entry() -> void:
	generate_quick_time_sequence()


func generate_quick_time_sequence() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	current_qtes = [QTEs[rng.randi_range(0, len(QTEs) - 1)]]
	successes = 0
	print("TODO: DISPLAY QTE BUTTONS")


func _unhandled_input(event: InputEvent) -> void:
	if current_input_state == InputState.PIT_LANE and not current_qtes.is_empty():
		if event.is_action(current_qtes[successes]):
			successes += 1
			if successes == len(current_qtes):
				print("passed QTE")
				current_qtes = []
		else:
			print("failed QTE")

#endregion


func attach_camera(cam: Camera2D) -> void:
	player_cam = cam
	print(remote_transform)
	remote_transform.remote_path = cam.get_path()
	cam.enabled = false


func toggle_player_camera(toggle: bool) -> void:
	player_cam.enabled = toggle


func get_speed() -> float:
	return linear_velocity.length()


func set_input_state(state: InputState) -> void:
	current_input_state = state


func on_race_completed() -> void:
	set_input_state(InputState.DISABLED)
