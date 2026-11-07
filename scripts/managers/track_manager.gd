class_name TrackManager extends Node

#exports
@export_category("Track Path")
@export var track_processor: TrackProcessor
@export var waypoints: Node
@export_category("Lap Tracking")
@export var start_gate: StartGate
@export var gates: Array[Area2D]
@export_category("Pit Paths")
@export var pit_entrance: PitGate
@export var pit_path: Path2D
@export var pit_exit: Path2D
@export_category("Other")
@export var pan_handler: PanHandler

#vars
var lap_count: int


func _ready() -> void:
	track_processor.build_waypoints(waypoints)
	await track_processor.build_completed


func get_first_waypoint() -> Waypoint:
	return track_processor.get_first_waypoint()


func get_lap_count() -> int:
	return lap_count


func set_lap_count(laps: int) -> void:
	lap_count = laps


func get_start_gate() -> StartGate:
	return start_gate


func get_gate_count() -> int:
	return len(gates)


func get_gate(index: int) -> Area2D:
	return gates[index]


func get_gate_index(gate: Area2D) -> int:
	var index: int = gates.find(gate)
	assert(index != -1)
	return index


func get_pit_entry() -> PitGate:
	return pit_entrance


func get_pit_path() -> PathFollow2D:
	var new_follow: PathFollow2D = PathFollow2D.new()
	pit_path.add_child(new_follow)
	new_follow.loop = false
	return new_follow


func get_pit_exit() -> PathFollow2D:
	var new_follow: PathFollow2D = PathFollow2D.new()
	pit_exit.add_child(new_follow)
	new_follow.loop = false
	return new_follow


func set_mirror_mode(mirror: bool) -> void:
	if mirror:
		start_gate.rotation_degrees += 180
		gates.reverse()


func assign_starts(cars: Array[Car]) -> void:
	start_gate.assign_starts(cars)


func flyby() -> void:
	await pan_handler.handle_flyby()
