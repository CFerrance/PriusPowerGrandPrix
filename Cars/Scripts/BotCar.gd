class_name BotCar extends Car

#enums
enum DrivingState {
	STANDBY,
	DRIVING,
	PIT_LANE,
}

#variables
var current_driving_state: DrivingState = DrivingState.STANDBY


func _physics_process(delta: float) -> void:
	return


func _apply_friction() -> void:
	if get_speed() < 5:
		linear_velocity = Vector2.ZERO
	var friction_force: Vector2 = linear_velocity * -1 * car_data.base_friction
	var drag_force: Vector2 = linear_velocity * linear_velocity.length() * -1 * car_data.drag
	apply_central_force(friction_force + drag_force)


func set_driving_state(state: DrivingState) -> void:
	current_driving_state = state


func on_pit_entry() -> void:
	pass


func on_race_completed() -> void:
	pass
