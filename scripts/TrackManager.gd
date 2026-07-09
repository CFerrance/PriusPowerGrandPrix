class_name TrackManager extends Node

#exports
@export_category("Lap Tracking")
@export var start_gate: StartGate
@export var gates: Array[Gate]
@export_category("Other")
@export var pan_handler: PanHandler

#vars
var lap_count: int


func get_lap_count() -> int:
	return lap_count


func set_lap_count(laps: int) -> void:
	lap_count = laps


func get_start_gate() -> StartGate:
	return start_gate


func get_gate_index(gate: Gate) -> int:
	var index: int = gates.find(gate)
	assert(index != -1)
	return index


func set_mirror_mode(mirror: bool) -> void:
	if mirror:
		start_gate.rotation_degrees += 180
		gates.reverse()


func assign_starts(cars: Array[Car]) -> void:
	start_gate.assign_starts(cars)


func flyby() -> void:
	await pan_handler.handle_flyby()
