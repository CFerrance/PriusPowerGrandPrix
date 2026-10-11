class_name RaceContext extends Node

#enums
enum RaceType {
	SINGLE,
	CUP,
	PRACTICE,
}

#constants
const BOT_COUNT: int = 5

#vars
var selected_race_type: RaceType
var selected_race_option: RaceOption
var player_team_name: String
var num_laps: int
var mirror_mode: bool
var car_dict: Dictionary[String, CarData]
var palette_dict: Dictionary[String, CarPalette]
var start_order: Array[String]

var race_queue: Array[TrackData]
var current_race_manager: RaceManager 

#dependencies
var game_manager: GameManager


func bind_dependencies(manager: GameManager) -> void:
	game_manager = manager


func set_race_choices(race_type: RaceType, race_option: RaceOption, player_team: String,
		car: CarData, palette: CarPalette, laps: int, mirror: bool) -> void:
	
	selected_race_type = race_type
	selected_race_option = race_option
	player_team_name = player_team
	num_laps = laps
	mirror_mode = mirror
	
	_prepare_cars(car, palette)
	
	race_queue = selected_race_option.get_race_queue()
	_mount_next_race()


func _prepare_cars(player_car: CarData, player_palette: CarPalette) -> void:
	start_order = []
	car_dict = {}
	
	#add bot cars to dictionary
	if selected_race_type != RaceType.PRACTICE:
		_choose_bot_cars(player_palette)
		start_order = car_dict.keys()
	
	#add player car (+ last)
	car_dict[player_team_name] = player_car
	palette_dict[player_team_name] = player_palette
	start_order.append(player_team_name)


func _choose_bot_cars(player_palette: CarPalette) -> void:
	#pick random car for each team
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	
	var available_cars: Array[CarData] = game_manager.get_available_cars()
	for team: Team in game_manager.get_base_teams():
		#correct car count
		if len(car_dict) >= BOT_COUNT:
			break
		#teams have different names and colors
		if player_palette.resource_path == team.preferred_palette.resource_path or player_team_name == team.team_name:
			continue
		
		car_dict[team.team_name] = available_cars[rng.randi_range(0, len(available_cars) - 1)]


func _mount_next_race() -> void:
	assert(len(race_queue) > 0)
	
	var race_manager_packed: PackedScene = load("res://Misc/Scenes/RaceManager.tscn")
	current_race_manager = race_manager_packed.instantiate()
	add_child(current_race_manager)
	
	current_race_manager.bind_dependencies(self)
	current_race_manager.set_race_essentials(race_queue[0], num_laps, mirror_mode)
	
	current_race_manager.race_completed.connect(race_finished)
	
	current_race_manager.handle_race(selected_race_type)


func race_finished() -> void:
	race_queue.pop_front()
	
	if current_race_manager.race_completed.is_connected(race_finished):
		current_race_manager.race_completed.disconnect(race_finished)
	
	#TODO log results
	
	current_race_manager.queue_free()
	
	if len(race_queue) > 0:
		_mount_next_race()
	else:
		game_manager.mount_main_menu_context()


func get_race_type() -> RaceType:
	return selected_race_type


func get_car_dict() -> Dictionary[String, CarData]:
	return car_dict.duplicate()


func get_player_team() -> String:
	return player_team_name


func get_palette_dict() -> Dictionary[String, CarPalette]:
	return palette_dict.duplicate()


func get_start_order() -> Array[String]:
	return start_order.duplicate()


func set_start_order(new: Array[String]) -> void:
	assert(len(new) == len(start_order))
	start_order = new


func request_level_restart() -> void:
	assert(selected_race_type == RaceType.PRACTICE)
	
	if current_race_manager.race_completed.is_connected(race_finished):
		current_race_manager.race_completed.disconnect(race_finished)
	
	current_race_manager.queue_free()
	
	_mount_next_race()


func request_quit_to_menu() -> void:
	game_manager.request_quit_to_menu()


func request_quit() -> void:
	game_manager.request_quit()
