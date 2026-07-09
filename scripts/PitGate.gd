class_name PitGate extends Node


func _on_body_entered(body: Node2D) -> void:
	var car: Car = body
	assert(car == null or car is Car)
	if car != null:
		car.on_pit_entry()
