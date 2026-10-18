class_name GameManager extends Node

#enums
enum Context {
	MAIN_MENU,
	TUTORIAL,
	RACE,
}

#exports
@export var available_cars: Array[CarData]
@export var base_teams: Array[Team]
@export var available_tracks: Array[TrackData]
@export var available_cups: Array[CupData]

#children
var current_context_type: Context
var current_context: Node


func _ready() -> void:
	mount_main_menu_context()


func mount_main_menu_context() -> void:
	if current_context:
		current_context.queue_free()
	
	var main_menu_packed: PackedScene = load("res://scenes/menus/main_menu.tscn")
	var main_menu: MainMenu = main_menu_packed.instantiate()
	main_menu.bind_dependencies(self)
	main_menu.selections_completed.connect(mount_race_context)
	main_menu.tutorial_selected.connect(mount_tutorial_context)
	
	current_context = main_menu
	current_context_type = Context.MAIN_MENU
	add_child(current_context)


func mount_tutorial_context() -> void:
	if current_context:
		current_context.queue_free()
	
	var tutorial_packed: PackedScene = load("res://scenes/contexts/tutorial_context.tscn")
	var tutorial: TutorialContext = tutorial_packed.instantiate()
	tutorial.bind_dependencies(self)
	
	current_context = tutorial
	current_context_type = Context.TUTORIAL
	add_child(current_context)


func mount_race_context(race_type: RaceContext.RaceType, race_option: RaceOption, player_team: String,
		car: CarData, palette: CarPalette, laps: int, mirror: bool) -> void:
	assert(current_context_type == Context.MAIN_MENU and current_context)
	
	current_context.queue_free()
	
	var race_context_packed: PackedScene = load("res://scenes/contexts/race_context.tscn")
	var race_context: RaceContext = race_context_packed.instantiate()
	current_context = race_context
	add_child(race_context)
	
	race_context.bind_dependencies(self)
	
	race_context.set_race_choices(race_type, race_option, player_team, car, 
			palette, laps, mirror)


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


func get_base_teams() -> Array[Team]:
	return base_teams.duplicate()


func request_quit_to_menu() -> void:
	mount_main_menu_context()


func request_quit() -> void:
	get_tree().quit()
