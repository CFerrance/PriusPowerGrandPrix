class_name Gate extends Node

@onready var trackManager = $"../.."

func _on_body_entered(body):
	if body is Car:
		print(self.name)
		body.lapData.try_add_gate(self)
