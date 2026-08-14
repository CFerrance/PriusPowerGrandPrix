class_name GameManager extends Node

#enums
enum RaceType {
	SINGLE,
	CUP,
	PRACTICE,
}

#exports
@export var available_cars: Array[CarData]
@export var bot_teams: Array[Team]
@export var available_tracks: Array[RaceOption]
@export var available_cups: Array[RaceOption]

#variables
var lap_count: int = 5
var mirror_mode: bool = false
var player_team_name: String = "Player Team"
var start_order: Array[String]
var score_dict: Dictionary[String, int]
var car_dict: Dictionary[String, CarData]
var palette_dict: Dictionary[String, CarPalette]

#constants
const main_menu_packed: PackedScene = preload("res://scenes/MainMenu.tscn")
const level_manager_packed: PackedScene = preload("res://scenes/LevelManager.tscn")
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


func on_selections_completed(option_type: RaceType, option: RaceOption,
		 selected_car: CarData, selected_palette: CarPalette) -> void:
	main_menu_manager.queue_free()
	
	#add bot cars
	if option_type != RaceType.PRACTICE:
		_choose_bot_cars(selected_palette)
	start_order = car_dict.keys()
	
	#add player car (+ last)
	car_dict[player_team_name] = selected_car
	palette_dict[player_team_name] = selected_palette
	start_order.append(player_team_name)
	
	#handle all tracks in queue one at a time
	for track: PackedScene in option.tracks:
		assert(level_manager == null)
		level_manager = level_manager_packed.instantiate()
		add_child(level_manager)
		if not level_manager.is_node_ready():
			await level_manager.ready
		level_manager.handle_level(option.name, track, option_type, lap_count, mirror_mode, car_dict, 
				player_team_name, start_order, palette_dict)
		await level_manager.level_completed
	
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
	return available_tracks.duplicate()


func get_cup_options() -> Array[RaceOption]:
	return available_cups.duplicate()


func get_available_cars() -> Array[CarData]:
	return available_cars.duplicate()


func request_quit() -> void:
	game_director.request_quit()
