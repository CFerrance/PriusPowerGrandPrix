class_name PitGate extends Node2D

#onready
@onready var collider: CollisionShape2D = $CollisionShape2D
@onready var deceleration_end: Node2D = $DecelerationEnd


func _on_body_entered(body: Node2D) -> void:
	var car: Car = body
	assert(car == null or car is Car)
	if car != null:
		car.on_pit_entry()


func get_exit_vector() -> Vector2:
	return transform.y


func get_progress(pos: Vector2) -> float:
	var local: Vector2 = self.to_local(pos)
	return clampf(local.y / (deceleration_end.position.y - collider.position.y), 0.0, 1.0)
