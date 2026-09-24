class_name RaceManager extends Node

#signals
signal race_completed

#constants
const SKIP_FLYBY: bool = false

#vars
var track_manager: TrackManager
var racing_enabled: bool
var race_time_elapsed: float
var cars: Array[Car] = []
var player_car: PlayerCarController
var standings_tracker: StandingsTracker 
var level_ui: LevelUI
var pause_menu: PauseMenu

#dependencies
var race_context: RaceContext


func bind_dependencies(context: RaceContext) -> void:
	race_context = context


func set_race_essentials(track: TrackData, laps: int, mirror: bool) -> void:
	track_manager = track.scene.instantiate()
	add_child(track_manager)
	
	track_manager.set_lap_count(laps)
	track_manager.set_mirror_mode(mirror)
	
	_load_cars()
	standings_tracker = StandingsTracker.new(cars)
	
	var level_ui_packed: PackedScene = load("res://UI/Scenes/LevelUI.tscn")
	level_ui = level_ui_packed.instantiate()
	add_child(level_ui)
	level_ui.bind_dependencies(self, player_car, track_manager)
	level_ui.set_level_name(track.name)
	
	var pause_menu_packed: PackedScene = load("res://UI/Scenes/PauseMenu.tscn")
	pause_menu = pause_menu_packed.instantiate()
	add_child(pause_menu)
	pause_menu.bind_dependencies(race_context)


func _process(delta: float) -> void:
	if racing_enabled:
		race_time_elapsed += delta


func handle_race(race_type: RaceContext.RaceType) -> void:
	#flyby
	if not SKIP_FLYBY:
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
	
	#podium + standings + next race
	await player_car.race_completed
	racing_enabled = false
	level_ui.toggle_hud(false)
	if race_type != RaceContext.RaceType.PRACTICE:
		level_ui.populate_podium(standings_tracker)
		level_ui.toggle_podium(true)
		await level_ui.continue_pressed
		level_ui.toggle_podium(false)
		if race_type == RaceContext.RaceType.CUP:
			level_ui.toggle_standings(true)
			await  level_ui.continue_pressed
	else:
		level_ui.toggle_practice_stats(true)
		await level_ui.continue_pressed
	
	race_completed.emit()


func _load_cars() -> void:
	#instantiate + configure cars
	cars = []
	var bots: Array[BotCar] = []
	var player_team: String = race_context.get_player_team()
	var car_dict: Dictionary[String, CarData] = race_context.get_car_dict()
	var palette_dict: Dictionary[String, CarPalette] = race_context.get_palette_dict()
	
	var bot_car_packed: PackedScene = load("res://Cars/Scenes/BotCar.tscn")
	for id: String in race_context.get_start_order():
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


func handle_level() -> void:
	race_completed.emit()


func is_racing_enabled() -> bool:
	return racing_enabled


func get_race_time_elapsed() -> float:
	return race_time_elapsed
