@abstract
class_name Car extends RigidBody2D

#signals
signal gate_passed
signal lap_completed
signal race_completed

#exports
@export var car_sprite: Sprite2D

#variables
var team_name: String
var car_data: CarData
var completed_laps: Array[float]
var passed_gates: Array[Gate]

#dependencies
var level_manager: LevelManager
var track_manager: TrackManager


func bind_dependencies(l_manager: LevelManager, t_manager: TrackManager) -> void:
	level_manager = l_manager
	track_manager = t_manager


func configure_car(team: String, data: CarData) -> void:
	team_name = team
	car_data = data
	self.mass = car_data.mass
	car_sprite.texture = car_data.sprite


#region Lap Tracking
func try_add_gate(gate: Gate) -> void:
	if _try_add_gate(gate):
		gate_passed.emit()


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
			completed_laps.append(Time.get_ticks_msec())
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


func get_laps_completed() -> int:
	return len(completed_laps)


func get_lap_time_msec() -> float:
	if len(completed_laps) == 0:
		return Time.get_ticks_msec() - level_manager.get_race_start()
	else:
		return Time.get_ticks_msec() - completed_laps[len(completed_laps) - 1]


func get_final_time_string() -> String:
	if len(completed_laps) >= track_manager.get_lap_count():
		return Utils.msec_to_time_string(completed_laps[track_manager.get_lap_count() - 1])
	else:
		return "DNF"


func get_best_lap_time_string() -> String:
	if len(completed_laps) == 0:
		return "--"
	
	var best_time: float = completed_laps[0] - level_manager.get_race_start()
	var best_lap: int = 0
	
	for i: int in range(1, len(completed_laps)):
		var lap_time: float = completed_laps[i] - completed_laps[i-1]
		if  lap_time < best_time:
			best_time = lap_time
			best_lap = i
	
	return "Lap " + str(best_lap + 1) + ": " + Utils.msec_to_time_string(best_time)


func get_average_lap_time_string() -> String:
	if len(completed_laps) == 0:
		return "--"
	
	var total_time: float = completed_laps[0] - level_manager.get_race_start()
	
	for i: int in range(1, len(completed_laps)):
		total_time += completed_laps[i] - completed_laps[i-1]
	
	total_time /= len(completed_laps)
	
	return Utils.msec_to_time_string(total_time)

#endregion


@abstract
func on_pit_entry() -> void


@abstract
func on_race_completed() -> void
