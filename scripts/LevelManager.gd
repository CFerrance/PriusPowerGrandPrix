class_name LevelManager extends Node

var cars: Array[Car]

var gameDirector: GameDirector
var gameManager: GameManager
var trackManager: TrackManager
var levelUI: LevelUI
var playerCar: PlayerCarController
var playerCamera: Camera2D

var playerCarScene = preload("res://scenes/PlayerCar.tscn")
var botCarScene = preload("res://scenes/BotCar.tscn")
var levelUIScene = preload("res://scenes/LevelUI.tscn")
var playerCameraScene = preload("res://scenes/PlayerCamera.tscn")

const SKIP_FLYBY := false

func _ready():
	gameDirector = get_tree().get_first_node_in_group("GameDirector")
	gameManager = get_tree().get_first_node_in_group("GameManager")
	self.add_to_group("LevelManager")

func handle_level():
	trackManager = gameDirector.add_scene(gameManager.get_current_race())
	trackManager.set_laps(gameManager.lapCount)
	trackManager.set_mirror_mode(gameManager.mirrorMode)
	
	levelUI = gameDirector.add_scene(levelUIScene)
	levelUI.connect_track_manager(trackManager)
	playerCamera = gameDirector.add_scene(playerCameraScene)
	playerCamera.enabled = false
	
	_load_cars()
	levelUI.connect_player_car(playerCar)
	playerCar.attach_camera(playerCamera)
	
	if not SKIP_FLYBY:
		await trackManager.flyby()
	
	levelUI.toggle_racing_ui(true)
	playerCamera.enabled = true
	playerCar.set_input_state(PlayerCarController.INPUT_STATES.REVVING)
	await levelUI.handle_start_lights()
	trackManager.toggle_lap_tracker(true)
	playerCar.set_input_state(PlayerCarController.INPUT_STATES.DRIVING)
	await trackManager.onPlayerFinished
	trackManager.toggle_lap_tracker(false)

func _load_cars():
	for id in gameManager.startOrder:
		var car: Car
		if id == gameManager.playerTeam:
			car = gameDirector.add_scene(playerCarScene)
			car.configure_car(gameManager.playerTeam, gameManager.selectedCar)
			playerCar = car
		else:
			car = gameDirector.add_scene(botCarScene)
			car.configure_car(id, gameManager.carDict[id])
		cars.append(car)
	trackManager.position_cars(cars)
	trackManager.attach_lap_data(cars)

func _show_player_scores():
	var playersSorted = gameManager.scoreDict.keys()
	playersSorted.sort_custom(_compare_scores)

func _compare_scores(a: String, b: String):
	if gameManager.scoreDict[a] == gameManager.scoreDict[b] and b == gameManager.playerTeam:
		return true
	else:
		return gameManager.scoreDict[a] > gameManager.scoreDict[b]
