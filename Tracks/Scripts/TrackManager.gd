class_name TrackManager extends Node

#exports
@export_category("Lap Tracking")
@export var start_gate: StartGate
@export var gates: Array[Gate]
@export_category("Pit Paths")
@export var pit_entrance: PitGate
@export var pit_path: Path2D
@export var pit_exit: Path2D
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


func get_gate_count() -> int:
	return len(gates)


func get_gate(index: int) -> Gate:
	return gates[index]


func get_gate_index(gate: Gate) -> int:
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
