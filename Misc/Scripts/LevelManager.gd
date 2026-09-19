class_name LevelManager extends Node

#signals
signal level_completed

#variables
var racing_enabled: bool
var race_time_elapsed: float
var cars: Array[Car]
var bots: Array[BotCar]
var level_ui: LevelUI

#constants
const SKIP_FLYBY: bool = false

#dependencies
var game_manager: GameManager

#children
var track_manager: TrackManager
var player_car: PlayerCarController
var pause_menu: PauseMenu 


func bind_dependencies(manager: GameManager) -> void:
	game_manager = manager


func _process(delta: float) -> void:
	if racing_enabled:
		race_time_elapsed += delta


func handle_level(track: TrackData, race_type: GameManager.RaceType, laps: int, 
		mirror: bool, car_dict: Dictionary[String, CarData], player_team: String, start_order: Array[String],
		palette_dict: Dictionary[String, CarPalette]) -> void:
	track_manager = track.scene.instantiate()
	add_child(track_manager)
	if not track_manager.is_node_ready():
		await track_manager.ready
	
	track_manager.set_lap_count(laps)
	track_manager.set_mirror_mode(mirror)
	
	_load_cars(car_dict, player_team, start_order, palette_dict)
	var standings_tracker: StandingsTracker = StandingsTracker.new(cars)
	
	var level_ui_packed: PackedScene = load("res://UI/Scenes/LevelUI.tscn")
	level_ui = level_ui_packed.instantiate()
	add_child(level_ui)
	if not level_ui.is_node_ready():
		await level_ui.ready
	level_ui.bind_dependencies(self, player_car, track_manager)
	
	var pause_menu_packed: PackedScene = load("res://UI/Scenes/PauseMenu.tscn")
	pause_menu = pause_menu_packed.instantiate()
	add_child(pause_menu)
	pause_menu.bind_dependencies(game_manager, self)
	
	#flyby
	if not SKIP_FLYBY:
		level_ui.set_level_name(track.name)
		level_ui.toggle_level_name(true)
		await track_manager.flyby()
		level_ui.toggle_level_name(false)
	
	#start sequence
	level_ui.toggle_hud(true)
	player_car.toggle_player_camera(true)
	player_car.set_input_state(PlayerCarController.InputState.REVVING)
	await level_ui.handle_start_lights()
	racing_enabled = true
	race_time_elapsed = 0.0
	player_car.set_input_state(PlayerCarController.InputState.DRIVING)
	_start_bot_cars()
	
	#podium + standings + next race
	await player_car.race_completed
	racing_enabled = false
	level_ui.toggle_hud(false)
	if race_type != GameManager.RaceType.PRACTICE:
		level_ui.populate_podium(standings_tracker)
		level_ui.toggle_podium(true)
		await level_ui.continue_pressed
		level_ui.toggle_podium(false)
		if race_type == GameManager.RaceType.CUP:
			level_ui.toggle_standings(true)
			await  level_ui.continue_pressed
	else:
		level_ui.toggle_practice_stats(true)
		await level_ui.continue_pressed
	
	level_completed.emit()


func _load_cars(car_dict: Dictionary[String, CarData], player_team: String, 
		start_order: Array[String], palette_dict: Dictionary[String, CarPalette]) -> void:
	#instantiate + configure cars
	cars = []
	bots = []
	var bot_car_packed: PackedScene = load("res://Cars/Scenes/BotCar.tscn")
	for id: String in start_order:
		var car: Car
		if id == player_team:
			var player_car_packed: PackedScene = load("res://Cars/Scenes/PlayerCar.tscn")
			car = player_car_packed.instantiate()
			player_car = car
		else:
			car = bot_car_packed.instantiate()
			bots.append(car)
		add_child(car)
		car.bind_dependencies(self, track_manager)
		car.configure_car(id, car_dict[id], palette_dict[id])
		cars.append(car)
	
	#attach player cam
	var player_cam_packed: PackedScene = load("res://Cars/Scenes/PlayerCamera.tscn")
	var player_cam: Camera2D = player_cam_packed.instantiate()
	add_child(player_cam)
	player_car.attach_camera(player_cam)
	#position cars
	track_manager.assign_starts(cars)


func _start_bot_cars() -> void:
	for bot: BotCar in bots:
		bot.set_driving_state(BotCar.DrivingState.DRIVING)


func is_racing_enabled() -> bool:
	return racing_enabled


func get_race_time_elapsed() -> float:
	return race_time_elapsed


func request_quit_to_menu() -> void:
	game_manager.request_quit_to_menu()


func request_quit() -> void:
	game_manager.request_quit()
