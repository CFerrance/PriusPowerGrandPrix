class_name Gate extends Node2D


func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, Car):
		var car: Car = body
		assert(car == null or car is Car)
		car.try_add_gate(self)
