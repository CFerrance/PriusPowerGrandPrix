class_name PlayerCarController extends CarController

#signals
signal gear_changed

enum Gear {
	LOW, 
	MID, 
	HIGH,
}

var current_gear: Gear
var driving_enabled: bool = true


func _physics_process(_delta: float) -> void:
	if driving_enabled:
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
	brake_light.hide()
	if Input.is_action_pressed("Brake"):
		var dot: float = forwards.dot(linear_velocity)
		if dot > 0:
			#speed and forwards are same direction, thus we brake
			acceleration = -forwards * car_data.brake_power
			brake_light.show()
		else:
			acceleration = -forwards * car_data.reverse_power
	elif Input.is_action_pressed("Accelerate"):
		acceleration = forwards * car_data.get_engine_power(current_gear, get_speed())
	apply_central_force(acceleration)


func _apply_friction() -> void:
	if get_speed() < 5 and not Input.is_action_pressed("Accelerate") and not Input.is_action_pressed("Brake"):
		linear_velocity = Vector2.ZERO
	var friction_force: Vector2 = linear_velocity * -1 * car_data.base_friction
	var drag_force: Vector2 = linear_velocity * linear_velocity.length() * -1 * car_data.drag
	apply_central_force(friction_force + drag_force)

#endregion


func toggle_driving_enabled(toggle: bool) -> void:
	driving_enabled = toggle


func get_speed() -> float:
	return linear_velocity.length()
