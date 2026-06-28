class_name PitGate extends Node

func _on_body_entered(body):
	if body is Car:
		body.on_pit_entry()
		if body is PlayerCarController:
			body.set_input_state(PlayerCarController.INPUT_STATES.PIT_LANE)
