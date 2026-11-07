class_name TutorialUI extends Node

@export var hud: Control
@export var speedometer: HudSpeedometer


func setup(player: PlayerCar) -> void:
	speedometer.bind_dependencies(player.get_car_controller() as PlayerCarController)


func _process(_delta: float) -> void:
	if speedometer:
		speedometer.set_speed_text()


func toggle_hud(toggle: bool) -> void:
	if toggle:
		hud.show()
	else:
		hud.hide()
