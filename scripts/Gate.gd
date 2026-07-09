class_name Gate extends Node2D


func _on_body_entered(body: Node2D) -> void:
	var car: Car = body
	assert(car == null or car is Car)
	if car != null:
		car.try_add_gate(self)
