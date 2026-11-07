class_name RaceUI extends Node

@export var hud: Control
@export var speedometer: HudSpeedometer
@export var hud_lap_tracker: HudLapTracker
@export var start_lights: StartLights

#dependencies
var race_manager: RaceManager


func bind_dependencies(r_manager: RaceManager) -> void:
	race_manager = r_manager


func setup(player: PlayerCar, laps: int) -> void:
	speedometer.bind_dependencies(player.get_car_controller() as PlayerCarController)
	
	hud_lap_tracker.bind_dependencies(player.get_lap_tracker())
	hud_lap_tracker.setup(laps)


func _process(_delta: float) -> void:
	speedometer.set_speed_text()
	
	if race_manager.is_racing_enabled():
		hud_lap_tracker.update_lap_time(race_manager.get_race_time_elapsed())


func toggle_hud(toggle: bool) -> void:
	if toggle:
		hud.show()
	else:
		hud.hide()
