class_name LevelUI extends Node

@onready var racingUI = $RacingUI
@onready var startLights = $StartLights

func connect_track_manager(trackManager: TrackManager):
	racingUI.connect_to_track_manager(trackManager)

func connect_player_car(playerCar: PlayerCarController):
	racingUI.connect_to_player(playerCar)

func toggle_racing_ui(toggle: bool):
	if toggle:
		racingUI.show()
	else:
		racingUI.hide()

func handle_start_lights():
	await startLights.handle_lights()
