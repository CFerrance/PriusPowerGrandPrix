class_name GameManager extends Node

#exports
@export var bot_car_choices: Array[CarData]

#variables
var lap_count: int = 5
var mirror_mode: bool = false
var player_team_name: String = "Player Team"
var start_order: Array[String]
var score_dict: Dictionary[String, int]
var car_dict: Dictionary[String, CarData]
var track_queue: Array[PackedScene]

#constants
const main_menu_packed: PackedScene = preload("res://scenes/MainMenu.tscn")
const level_manager_packed: PackedScene = preload("res://scenes/LevelManager.tscn")
const TEAM_NAMES: Array[String] = ["Furrari", "Purrcedes", "Catillac", "Pawsche", "MeowClaren", "Meowdi"]
const BOT_COUNT: int = 5

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


func on_selections_completed(option_type: MainMenuManager.RaceType, option: RaceOption,
		 selected_car: CarData) -> void:
	main_menu_manager.queue_free()
	
	#add bot cars
	if option_type != MainMenuManager.RaceType.PRACTICE:
		_choose_bot_cars()
	start_order = car_dict.keys()
	
	#add player car (+ last)
	car_dict[player_team_name] = selected_car
	start_order.append(player_team_name)
	
	#handle all tracks in queue one at a time
	track_queue = option.tracks.duplicate()
	_start_next_track()


func _start_next_track() -> void:
	assert(level_manager == null)
	level_manager = level_manager_packed.instantiate()
	add_child(level_manager)
	if not level_manager.is_node_ready():
		await level_manager.ready
	var next_track: PackedScene = track_queue.pop_front()
	level_manager.handle_level(next_track, lap_count, mirror_mode, car_dict, 
			player_team_name, start_order)
	level_manager.race_completed.connect(on_race_completed)


func on_race_completed() -> void:
	if track_queue.is_empty():
		print("All races complete!")
	else:
		_start_next_track()
	pass


func _choose_bot_cars() -> void:
	#pick random car for each team
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	for team: String in TEAM_NAMES:
		if len(car_dict) >= BOT_COUNT:
			break
		car_dict[team] = bot_car_choices[rng.randi_range(0, len(bot_car_choices) - 1)]


func request_quit() -> void:
	game_director.request_quit()
