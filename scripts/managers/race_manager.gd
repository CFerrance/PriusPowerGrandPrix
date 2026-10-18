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
var hud: HUD
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
	
	var hud_packed: PackedScene = load("res://scenes/hud/hud.tscn")
	hud = hud_packed.instantiate()
	add_child(hud)
	hud.bind_dependencies(self, player_car, track_manager)
	hud.set_level_name(track.name)
	
	var pause_menu_packed: PackedScene = load("res://scenes/menus/pause_menu.tscn")
	pause_menu = pause_menu_packed.instantiate()
	add_child(pause_menu)
	pause_menu.bind_dependencies(race_context)


func _process(delta: float) -> void:
	if racing_enabled:
		race_time_elapsed += delta


func handle_race(race_type: RaceContext.RaceType) -> void:
	#flyby
	if not SKIP_FLYBY:
		hud.toggle_level_name(true)
		await track_manager.flyby()
		hud.toggle_level_name(false)
	
	#start sequence
	hud.toggle_hud(true)
	player_car.toggle_player_camera(true)
	player_car.set_input_state(PlayerCarController.InputState.REVVING)
	await hud.handle_start_lights()
	racing_enabled = true
	race_time_elapsed = 0.0
	player_car.set_input_state(PlayerCarController.InputState.DRIVING)
	
	#podium + standings + next race
	await player_car.race_completed
	racing_enabled = false
	hud.toggle_hud(false)
	if race_type != RaceContext.RaceType.PRACTICE:
		hud.populate_podium(standings_tracker)
		hud.toggle_podium(true)
		await hud.continue_pressed
		hud.toggle_podium(false)
		if race_type == RaceContext.RaceType.CUP:
			hud.toggle_standings(true)
			await  hud.continue_pressed
	else:
		hud.toggle_practice_stats(true)
		await hud.continue_pressed
	
	race_completed.emit()


func _load_cars() -> void:
	#instantiate + configure cars
	cars = []
	var bots: Array[BotCar] = []
	var player_team: String = race_context.get_player_team()
	var car_dict: Dictionary[String, CarData] = race_context.get_car_dict()
	var palette_dict: Dictionary[String, CarPalette] = race_context.get_palette_dict()
	
	var bot_car_packed: PackedScene = load("res://scenes/cars/bot_car.tscn")
	for id: String in race_context.get_start_order():
		var car: Car
		if id == player_team:
			var player_car_packed: PackedScene = load("res://scenes/cars/player_car.tscn")
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
	var player_cam_packed: PackedScene = load("res://scenes/misc/player_camera.tscn")
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
