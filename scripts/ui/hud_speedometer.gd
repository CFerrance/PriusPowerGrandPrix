class_name HudSpeedometer extends Node

@export var speed_text: Label
@export var gear_text: Label

var player_car_controller: PlayerCarController


func bind_dependencies(player_controller: PlayerCarController) -> void:
	if player_car_controller == null:
		push_error("Null player controller passed to speedometer")
	
	player_car_controller = player_controller
	player_car_controller.gear_changed.connect(_set_gear)
	_set_gear(0)


func set_speed_text() -> void:
	var speed: int = Utils.get_cosmetic_speed(player_car_controller.get_speed())
	speed_text.text = str(roundi(speed))


func _set_gear(gear: int) -> void:
	if gear == 0:
		gear_text.text = "ECO"
	elif gear == 1:
		gear_text.text = "NORM."
	else:
		gear_text.text = "POWER"
