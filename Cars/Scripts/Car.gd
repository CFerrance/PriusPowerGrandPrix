@abstract
class_name Car extends RigidBody2D

#signals
signal gate_passed
signal lap_completed
signal race_completed

#exports
@export var car_sprite: Sprite2D
@export var collider: CollisionShape2D

#variables
var team_name: String
var car_data: CarData
var completed_laps: Array[float]
var passed_gates: Array[Gate]
var last_gate_sec: float

#constants
const PIT_SPEED: float = 250.0

#dependencies
var level_manager: LevelManager
var track_manager: TrackManager


func bind_dependencies(l_manager: LevelManager, t_manager: TrackManager) -> void:
	level_manager = l_manager
	track_manager = t_manager


func configure_car(team: String, data: CarData, palette: CarPalette) -> void:
	team_name = team
	car_data = data
	
	#collision
	self.mass = car_data.mass
	collider.position.y = car_data.collider_offset
	var collision_shape: CapsuleShape2D = collider.shape as CapsuleShape2D
	collision_shape.height = car_data.collider_height
	collision_shape.radius = car_data.collider_radius
	
	#visuals
	car_sprite.texture = car_data.sprite
	car_sprite.material = car_sprite.material.duplicate()
	var shader_material: ShaderMaterial = car_sprite.material as ShaderMaterial
	shader_material.set_shader_parameter("replacement_palette", palette.palette)


#region Lap Tracking
func try_add_gate(gate: Gate) -> void:
	if _try_add_gate(gate):
		gate_passed.emit()
		last_gate_sec = level_manager.get_race_time_elapsed()


func _try_add_gate(gate: Gate) -> bool:
	if not level_manager.is_racing_enabled():
		return false
	if gate == track_manager.get_start_gate():
		if len(completed_laps) == 0 and len(passed_gates) == 0:
			#passing start lap one
			passed_gates.append(gate)
			return true
		elif len(passed_gates) == track_manager.get_gate_count() + 1:
			#completing a lap
			completed_laps.append(level_manager.get_race_time_elapsed())
			passed_gates = []
			passed_gates.append(gate)
			lap_completed.emit()
			if len(completed_laps) == track_manager.get_lap_count():
				race_completed.emit()
			return true
		return false
	else:
		if track_manager.get_gate_index(gate) == len(passed_gates) - 1:
			passed_gates.append(gate)
			print(len(passed_gates))
			return true
		return false


func get_next_gate() -> Gate:
	print(track_manager.get_gate(get_gates_this_lap()).name)
	return track_manager.get_gate(get_gates_this_lap())


func get_laps_completed() -> int:
	return len(completed_laps)


func get_gates_this_lap() -> int:
	return len(passed_gates)


func get_last_gate_sec() -> float:
	if len(passed_gates) == 0:
		return level_manager.get_race_time_elapsed()
	return last_gate_sec


func get_lap_time_sec() -> float:
	if len(completed_laps) == 0:
		return level_manager.get_race_time_elapsed()
	else:
		return level_manager.get_race_time_elapsed() - completed_laps[len(completed_laps) - 1]


func get_final_time_string() -> String:
	if len(completed_laps) >= track_manager.get_lap_count():
		return Utils.sec_to_time_string(completed_laps[track_manager.get_lap_count() - 1])
	else:
		return "DNF"


func get_best_lap_time_string() -> String:
	if len(completed_laps) == 0:
		return "--"
	
	var best_time: float = completed_laps[0]
	var best_lap: int = 0
	
	for i: int in range(1, len(completed_laps)):
		var lap_time: float = completed_laps[i] - completed_laps[i-1]
		if  lap_time < best_time:
			best_time = lap_time
			best_lap = i
	
	return "Lap " + str(best_lap + 1) + ": " + Utils.sec_to_time_string(best_time)


func get_average_lap_time_string() -> String:
	if len(completed_laps) == 0:
		return "--"
	
	var total_time: float = completed_laps[track_manager.get_lap_count() - 1]
	return Utils.sec_to_time_string(total_time / track_manager.get_lap_count())

#endregion


func get_speed() -> float:
	return linear_velocity.length()


@abstract
func on_pit_entry() -> void


@abstract
func on_race_completed() -> void
