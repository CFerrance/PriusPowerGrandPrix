class_name LevelManager extends Node

#signals
signal level_completed

#exports

#variables
var player_car: PlayerCarController
var racing_enabled: bool
var race_start_time: int

#constants
const SKIP_FLYBY: bool = false
const player_car_packed: PackedScene = preload("res://scenes/PlayerCar.tscn")
const player_camera_packed: PackedScene = preload("res://scenes/PlayerCamera.tscn")
const bot_car_packed: PackedScene = preload("res://scenes/BotCar.tscn")
const level_ui_packed: PackedScene = preload("res://scenes/LevelUI.tscn")

#dependencies
var game_manager: GameManager

#children
var track_manager: TrackManager
var cars: Array[Car]
var level_ui: LevelUI


func bind_dependencies(manager: GameManager) -> void:
	game_manager = manager


func handle_level(race_name : String, race: PackedScene, race_type: GameManager.RaceType, laps: int, 
		mirror: bool, car_dict: Dictionary[String, CarData], player_team: String, start_order: Array[String],
		palette_dict: Dictionary[String, CarPalette]) -> void:
	track_manager = race.instantiate()
	add_child(track_manager)
	if not track_manager.is_node_ready():
		await track_manager.ready
	
	track_manager.set_lap_count(laps)
	track_manager.set_mirror_mode(mirror)
	
	_load_cars(car_dict, player_team, start_order, palette_dict)
	var standings_tracker: StandingsTracker = StandingsTracker.new(cars)
	
	level_ui = level_ui_packed.instantiate()
	add_child(level_ui)
	if not level_ui.is_node_ready():
		await level_ui.ready
	level_ui.bind_dependencies(self, player_car, track_manager)
	
	#flyby
	if not SKIP_FLYBY:
		level_ui.set_level_name(race_name)
		level_ui.toggle_level_name(true)
		await track_manager.flyby()
		level_ui.toggle_level_name(false)
	
	#start sequence
	level_ui.toggle_hud(true)
	player_car.toggle_player_camera(true)
	player_car.set_input_state(PlayerCarController.InputState.REVVING)
	await level_ui.handle_start_lights()
	racing_enabled = true
	race_start_time = Time.get_ticks_msec()
	player_car.set_input_state(PlayerCarController.InputState.DRIVING)
	
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
	self.queue_free()


func _load_cars(car_dict: Dictionary[String, CarData], player_team: String, 
		start_order: Array[String], palette_dict: Dictionary[String, CarPalette]) -> void:
	#instantiate + configure cars
	cars = []
	for id: String in start_order:
		var car: Car
		if id == player_team:
			car = player_car_packed.instantiate()
			player_car = car
		else:
			car = bot_car_packed.instantiate()
		add_child(car)
		car.bind_dependencies(self, track_manager)
		car.configure_car(id, car_dict[id], palette_dict[id])
		cars.append(car)
	
	#attach player cam
	var player_cam: Camera2D = player_camera_packed.instantiate()
	add_child(player_cam)
	player_car.attach_camera(player_cam)
	#position cars
	track_manager.assign_starts(cars)


func is_racing_enabled() -> bool:
	return racing_enabled


func get_race_start() -> int:
	return race_start_time
