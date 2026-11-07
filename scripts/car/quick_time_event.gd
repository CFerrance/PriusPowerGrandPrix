class_name QuickTimeEvent extends Node

signal quick_time_finished

enum QTE_Result {
	PASSED,
	FAILED,
	TOO_SLOW,
}

@export_category("Quick Time Events")
@export var qtes: Array[StringName]
@export var qte_count: int
@export var qte_time_limit: float = 5.0

var current_qtes: Array[StringName]
var successes: int

#dependencies
var qte_display: QTE_Display


func bind_dependencies(display: QTE_Display) -> void:
	qte_display = display


func handle_qte(count: int, time_limit: float) -> void:
	_generate_quick_time_sequence(count)
	await get_tree().create_timer(time_limit).timeout
	if !current_qtes.is_empty():
		quick_time_finished.emit(QTE_Result.TOO_SLOW)


func _generate_quick_time_sequence(count: int) -> void:
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	
	current_qtes = []
	for i: int in range(count):
		current_qtes.append(qtes[rng.randi_range(0, len(qtes) - 1)])
	
	successes = 0
	qte_display.display_qte_sequence(current_qtes)


func _unhandled_input(event: InputEvent) -> void:
	if current_qtes.is_empty() or !event.is_pressed():
		return
	
	for qte: StringName in qtes:
		if event.is_action_pressed(qte):
			if qte == current_qtes[successes]:
				successes += 1
				print("Success")
				if successes == len(current_qtes):
					print("passed QTE")
					current_qtes.clear()
					qte_display.clear_sequence()
					quick_time_finished.emit(QTE_Result.PASSED)
			else:
				print("failed QTE")
				current_qtes.clear()
				qte_display.clear_sequence()
				quick_time_finished.emit(QTE_Result.FAILED)
