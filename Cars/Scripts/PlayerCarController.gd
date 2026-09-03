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
@export var brake_light: PointLight2D
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
	freeze_mode = RigidBody2D.FREEZE_MODE_STATIC


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

#region Pit Lane
func on_pit_entry() -> void:
	set_input_state(InputState.PIT_LANE)
	current_gear = Gear.LOW
	gear_changed.emit(current_gear)
	brake_light.show()
	await _handle_deceleration_zone()
	brake_light.hide()
	set_collision_mask_value(1, false)
	set_collision_mask_value(2, false)
	await _handle_pit_navigation()
	_generate_quick_time_sequence()
	await get_tree().create_timer(qte_time_limit).timeout
	if current_qtes.is_empty():
		return
	else:
		print("TOO SLOW, ADMINISTERING PENALTY")
		current_qtes.clear()
		await get_tree().create_timer(too_slow_penalty).timeout
		print("PENALTY COMPLETE")
		_exit_pit()


func _exit_pit() -> void:
	await _handle_pit_exit()
	set_collision_mask_value(1, true)
	set_collision_mask_value(2, true)
	linear_velocity = -transform.y * PIT_SPEED
	set_input_state(InputState.DRIVING)


func _handle_deceleration_zone() -> void:
	var deceleration_zone: PitGate = track_manager.get_pit_entry()
	var entry_speed: float = get_speed()
	var entry_direction: Vector2 = -transform.y
	var exit_direction: Vector2 = deceleration_zone.get_exit_vector()
	while true:
		var progress: float = deceleration_zone.get_progress(self.global_position)
		if progress >= 1.0:
			linear_velocity = Vector2.ZERO
			return
		var speed: float = lerpf(entry_speed, PIT_SPEED, progress)
		var direction: Vector2 = entry_direction.slerp(exit_direction, progress)
		linear_velocity = direction * speed
		rotation = linear_velocity.angle() + deg_to_rad(90)
		await get_tree().physics_frame


func _handle_pit_navigation() -> void:
	var entry_follow: PathFollow2D = track_manager.get_pit_path()
	#v_offset is offset perpendicular to curve
	var elapsed_time: float = 0.0
	var initial_offset: float = entry_follow.transform.y.dot(global_position - entry_follow.global_position) 
	entry_follow.v_offset = initial_offset
	var entry_angle: float = -transform.y.angle() - deg_to_rad(90)
	var correction_angle: float = (entry_follow.transform.x * PIT_SPEED - transform.x * initial_offset).angle() + deg_to_rad(90)
	while true:
		if entry_follow.progress_ratio >= 1.0:
			entry_follow.queue_free()
			return
		entry_follow.progress += PIT_SPEED * get_process_delta_time()
		elapsed_time += get_process_delta_time()
		global_position = entry_follow.global_position
		if elapsed_time > 1.0:
			entry_follow.v_offset = 0.0
			rotation = entry_follow.transform.x.angle() + deg_to_rad(90)
		else:
			var smooth_correct: float = 1 - absf(2 * elapsed_time - 1)
			entry_follow.v_offset = lerpf(initial_offset, 0.0, clampf(elapsed_time, 0.0, 1.0))
			rotation = lerp_angle(entry_angle, correction_angle, smooth_correct)
		await get_tree().process_frame


func _handle_pit_exit() -> void:
	var exit_follow: PathFollow2D = track_manager.get_pit_exit()
	while true:
		if exit_follow.progress_ratio >= 1.0:
			exit_follow.queue_free()
			return
		exit_follow.progress += PIT_SPEED * get_process_delta_time()
		global_position = exit_follow.global_position
		rotation = exit_follow.transform.x.angle() + deg_to_rad(90)
		await get_tree().process_frame


func _generate_quick_time_sequence() -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	current_qtes = [QTEs[rng.randi_range(0, len(QTEs) - 1)]]
	successes = 0
	print("TODO: DISPLAY QTE BUTTONS")
	print(current_qtes)


func _unhandled_input(event: InputEvent) -> void:
	if current_input_state == InputState.PIT_LANE and not current_qtes.is_empty():
		if event.is_action(current_qtes[successes]):
			successes += 1
			print("Success")
			if successes == len(current_qtes):
				print("passed QTE")
				current_qtes = []
				_exit_pit()
		else:
			print("failed QTE")
			current_qtes.clear()
			await get_tree().create_timer(incorrect_penalty).timeout
			_exit_pit()

#endregion


func attach_camera(cam: Camera2D) -> void:
	player_cam = cam
	print(remote_transform)
	remote_transform.remote_path = cam.get_path()
	cam.enabled = false


func get_speed_cosmetic() -> int:
	if current_input_state == InputState.DRIVING:
		return int(get_speed() / 10)
	elif current_input_state == InputState.PIT_LANE and current_qtes.is_empty():
		return int(PIT_SPEED / 10)
	return 0

func toggle_player_camera(toggle: bool) -> void:
	player_cam.enabled = toggle


func set_input_state(state: InputState) -> void:
	current_input_state = state


func on_race_completed() -> void:
	set_input_state(InputState.DISABLED)
