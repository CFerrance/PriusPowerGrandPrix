class_name GameManager extends Node

#enums
enum RaceType {
	SINGLE,
	CUP,
	PRACTICE,
	TUTORIAL,
}

#exports
@export var tutorial_track: TrackData
@export var available_cars: Array[CarData]
@export var bot_teams: Array[Team]
@export var available_tracks: Array[TrackData]
@export var available_cups: Array[CupData]

#variables
var lap_count: int = 5
var mirror_mode: bool = false
var selected_race_type: RaceType
var race_queue: Array[TrackData] 
var player_team_name: String = "Player Team"
var start_order: Array[String]
var score_dict: Dictionary[String, int]
var car_dict: Dictionary[String, CarData]
var palette_dict: Dictionary[String, CarPalette]

#constants
const BOT_COUNT: int = 1

#dependencies
var game_director: GameDirector

#children
var main_menu_manager: MainMenuManager
var level_manager: LevelManager


func bind_dependencies(director : GameDirector) -> void:
	game_director = director


func _ready() -> void:
	_build_children()
	_bind_child_dependencies()
	_setup()


func _build_children() -> void:
	var main_menu_packed: PackedScene = load("res://UI/Scenes/MainMenu.tscn")
	main_menu_manager = main_menu_packed.instantiate()
	add_child(main_menu_manager)


func _bind_child_dependencies() -> void:
	main_menu_manager.bind_dependencies(self)


func _setup() -> void:
	main_menu_manager.selections_completed.connect(on_selections_completed)
	car_dict = {}
	score_dict = {}
	start_order = []
	mirror_mode = false
	palette_dict = {}
	for team: Team in bot_teams:
		palette_dict[team.team_name] = team.preferred_palette


func start_tutorial() -> void:
	pass


func on_selections_completed(option_type: RaceType, option: RaceOption,
		 selected_car: CarData, selected_palette: CarPalette) -> void:
	
	selected_race_type = option_type
	assert(selected_race_type != RaceType.TUTORIAL)
	
	main_menu_manager.queue_free()
	
	#add bot cars to dictionary
	if option_type != RaceType.PRACTICE:
		_choose_bot_cars(selected_palette)
		start_order = car_dict.keys()
	
	#add player car (+ last)
	car_dict[player_team_name] = selected_car
	palette_dict[player_team_name] = selected_palette
	start_order.append(player_team_name)
	
	#create race queue
	race_queue = option.get_race_queue()
	
	_start_next_race()


func _start_next_race() -> void:
	#add level manager to scene
	assert(level_manager == null)
	assert(len(race_queue) > 0)
	
	var track: TrackData = race_queue[0]
	
	var level_manager_packed: PackedScene = load("res://Misc/Scenes/LevelManager.tscn")
	level_manager = level_manager_packed.instantiate()
	add_child(level_manager)
	if not level_manager.is_node_ready():
		await level_manager.ready
	level_manager.bind_dependencies(self)
	
	#handle level and connect to level complete
	level_manager.handle_level(track, selected_race_type, lap_count, mirror_mode, 
			car_dict, player_team_name, start_order, palette_dict)
	level_manager.level_completed.connect(on_race_finished)


func on_race_finished() -> void:
	race_queue.pop_front()
	
	if level_manager.level_completed.is_connected(on_race_finished):
		level_manager.level_completed.disconnect(on_race_finished)
	
	level_manager.queue_free()
	level_manager = null
	
	if len(race_queue) > 0:
		_start_next_race()
	else:
		#restart...
		_build_children()
		_bind_child_dependencies()
		_setup()


func _choose_bot_cars(player_palette: CarPalette) -> void:
	#pick random car for each team
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	
	for team: Team in bot_teams:
		#correct car count
		if len(car_dict) >= BOT_COUNT:
			break
		#teams have different names and colors
		if player_palette.resource_path == team.preferred_palette.resource_path or player_team_name == team.team_name:
			continue
		
		car_dict[team.team_name] = available_cars[rng.randi_range(0, len(available_cars) - 1)]


func get_track_options() -> Array[RaceOption]:
	var tracks: Array[RaceOption] = []
	for track: TrackData in available_tracks:
		tracks.append(track as RaceOption)
	return tracks


func get_cup_options() -> Array[RaceOption]:
	var cups: Array[RaceOption] = []
	for cup: CupData in available_cups:
		cups.append(cup as RaceOption)
	return cups


func get_available_cars() -> Array[CarData]:
	return available_cars.duplicate()


func get_race_type() -> RaceType:
	return selected_race_type


func request_level_restart() -> void:
	assert(selected_race_type == RaceType.PRACTICE or selected_race_type == RaceType.TUTORIAL)
	
	if level_manager.level_completed.is_connected(on_race_finished):
		level_manager.level_completed.disconnect(on_race_finished)
	
	level_manager.queue_free()
	level_manager = null
	
	_start_next_race()


func request_quit_to_menu() -> void:
	if level_manager.level_completed.is_connected(on_race_finished):
		level_manager.level_completed.disconnect(on_race_finished)
	
	level_manager.queue_free()
	level_manager = null
	race_queue.clear()
	
	#restart...
	_build_children()
	_bind_child_dependencies()
	_setup()


func request_quit() -> void:
	game_director.request_quit()
