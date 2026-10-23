class_name BotCar extends Car

enum DrivingState {
	IDLE,
	DRIVING,
}

@export var show_target: bool = true
@export var target_sprite: Sprite2D
@export var waypoint_distance: float = 75.0

const STEERING_MAX: float = 25.0

var current_driving_state: DrivingState = DrivingState.IDLE
var adjusted_waypoint_target: Vector2 = Vector2.ZERO
var steer_reaction: float = STEERING_MAX
var target_speed: float = 500
var next_waypoint: Waypoint


func _ready() -> void:
	if !show_target:
		target_sprite.hide()


func _physics_process(delta: float) -> void:
	if current_driving_state != DrivingState.DRIVING or next_waypoint == null:
		return
	
	var target_angle: float = (adjusted_waypoint_target - global_position).angle() + deg_to_rad(90.0)
	rotation = lerp_angle(rotation, target_angle, steer_reaction * delta)
	linear_velocity = lerp(linear_velocity, target_speed * -transform.y, delta)
	update_waypoint()


func set_next_waypoint(waypoint: Waypoint) -> void:
	next_waypoint = waypoint
	adjusted_waypoint_target = waypoint.global_position
	target_sprite.global_position = adjusted_waypoint_target


func update_waypoint() -> void:
	if global_position.distance_to(adjusted_waypoint_target) < waypoint_distance:
		set_next_waypoint(next_waypoint.next_waypoint)


func set_driving_state(state: DrivingState) -> void:
	current_driving_state = state


func on_pit_entry() -> void:
	pass


func on_race_completed() -> void:
	pass
