class_name TutorialContext extends GameContext

var tutorial_manager: TutorialManager

const TUTORIAL_TRACK_DATA: StringName = "res://resources/race_options/track_data/tutorial_track.tres" 
const TUTORIAL_CAR_DATA: StringName = "res://resources/car_data/prius.tres"


func setup() -> void:
	var driving_school_packed: PackedScene = load("res://scenes/tracks/driving_school.tscn")
	tutorial_manager = driving_school_packed.instantiate()
	add_child(tutorial_manager)
	tutorial_manager.bind_dependencies(self)
	tutorial_manager.setup()


func load_tutorial_race() -> void:
	var tutorial_track_data: TrackData = load(TUTORIAL_CAR_DATA) as TrackData
	var tutorial_car_data: CarData = load(TUTORIAL_CAR_DATA) as CarData
	
	game_manager.mount_race_context(RaceContext.RaceType.SINGLE, tutorial_track_data, 
		"Player", tutorial_car_data, null, 5, false)


func request_restart() -> void:
	tutorial_manager.queue_free()
	setup()


func is_restartable() -> bool:
	return true
