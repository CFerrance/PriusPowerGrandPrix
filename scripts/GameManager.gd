class_name GameManager extends Node

@export var botCarChoices: Array[CarData]

var currentRace: int
var selectedRaceType: RACE_TYPE:
	get: return selectedRaceType
var selectedRaceOption: RaceOption:
	get: return selectedRaceOption
var selectedCar: CarData:
	get: return selectedCar
var lapCount := 3
var mirrorMode := false:
	get: return mirrorMode
var playerTeam := "PlayerTeam"
var startOrder: Array[String]
var scoreDict: Dictionary[String, int]
var carDict: Dictionary[String, CarData]

var gameDirector: GameDirector
var levelManager: LevelManager

var levelManagerScene = preload("res://scenes/LevelManager.tscn")

const BOT_COUNT := 5
var TEAM_NAMES = ["Furrari", "Purrcedes", "Catillac", "Pawsche", "MeowClaren", "Meowdi"]:
	get: return TEAM_NAMES.duplicate()

enum RACE_TYPE{
	SINGLE,
	PRIX,
	PRACTICE
}

func _ready():
	gameDirector = get_tree().get_first_node_in_group("GameDirector")
	currentRace = 0

func set_race_type(raceType: RACE_TYPE):
	selectedRaceType = raceType

func set_race_option(raceOption: RaceOption):
	selectedRaceOption = raceOption

func set_car(car: CarData):
	selectedCar = car

func choose_bot_cars():
	var rng = RandomNumberGenerator.new()
	for team in TEAM_NAMES:
		if len(carDict) >= BOT_COUNT:
			break
		carDict[team] = botCarChoices[rng.randi_range(0, len(botCarChoices) - 1)]

func start_game():
	levelManager = gameDirector.add_scene(levelManagerScene)
	if selectedRaceType != RACE_TYPE.PRACTICE:
		choose_bot_cars()
		startOrder = carDict.keys()
	carDict[playerTeam] = selectedCar
	startOrder.append(playerTeam)
	levelManager.handle_level()

func get_current_race():
	return selectedRaceOption.tracks[currentRace]
