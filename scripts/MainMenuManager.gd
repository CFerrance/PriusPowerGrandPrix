class_name MainMenuManager extends Node

@export_category("References")
@export var background : TextureRect
@export var titleText: Control
@export var titleButtons: Control
@export var optionsMenu: Control
@export var credits: Control
@export var raceOptionsParent: Control
@export var carOptionsParent: Control

@export_category("Data")
@export var tracks: Array[RaceOption]
@export var prixs: Array[RaceOption]
@export var cars: Array[CarData]

@export_category("Assets")
@export var startBackground: Texture2D
@export var selectionBackground: Texture2D

@onready var startScreen:= $StartScreen
@onready var modeSelectScreen:= $ModeSelectScreen
@onready var trackSelectScreen:= $TrackSelectScreen
@onready var carSelectScreen:= $CarSelectScreen

var gameDirector: GameDirector
var gameManager: GameManager
var currentScreen := SCREEN.START
var trackSelectButtons = []
var carSelectButtons = []

enum SCREEN {
	START,
	MODE_SELECT,
	TRACK_SELECT,
	CAR_SELECT
}

func _ready():
	gameDirector = get_tree().get_first_node_in_group("GameDirector")
	gameManager = get_tree().get_first_node_in_group("GameManager")

func _on_play_button_pressed():
	_switch_screen(SCREEN.MODE_SELECT)

func _on_options_button_pressed():
	_toggle_options(true)

func _on_credits_button_pressed():
	_toggle_credits(true)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_options_back_button_pressed():
	_toggle_options(false)

func _on_single_button_pressed():
	gameManager.set_race_type(GameManager.RACE_TYPE.SINGLE)
	_switch_screen(SCREEN.TRACK_SELECT)

func _on_prix_button_pressed():
	gameManager.set_race_type(GameManager.RACE_TYPE.PRIX)
	_switch_screen(SCREEN.TRACK_SELECT)

func _on_practice_button_pressed():
	gameManager.set_race_type(GameManager.RACE_TYPE.PRACTICE)
	_switch_screen(SCREEN.TRACK_SELECT)

func _on_ready_button_pressed():
	_start_game()

func _switch_screen(newScreen: SCREEN):
	currentScreen = newScreen
	startScreen.hide()
	modeSelectScreen.hide()
	trackSelectScreen.hide()
	carSelectScreen.hide()
	
	match newScreen:
		SCREEN.START:
			_set_background(startBackground)
			startScreen.show()
		
		SCREEN.MODE_SELECT:
			_set_background(startBackground)
			modeSelectScreen.show()
		
		SCREEN.TRACK_SELECT:
			_set_background(selectionBackground)
			trackSelectScreen.show()
			if gameManager.selectedRaceType == GameManager.RACE_TYPE.SINGLE or gameManager.selectedRaceType == GameManager.RACE_TYPE.PRACTICE:
				_display_race_options(tracks)
			elif gameManager.selectedRaceType == GameManager.RACE_TYPE.PRIX:
				_display_race_options(prixs)
		
		SCREEN.CAR_SELECT:
			_set_background(selectionBackground)
			carSelectScreen.show()
			_display_car_options()

func _set_background(bg: Texture2D):
	background.texture = bg

func _toggle_options(toggle: bool):
	if currentScreen != SCREEN.START:
		push_error("Not on start screen!")
	
	if toggle:
		titleText.hide()
		titleButtons.hide()
		optionsMenu.show()
	else:
		titleText.show()
		titleButtons.show()
		optionsMenu.hide()

func _toggle_credits(toggle: bool):
	if currentScreen != SCREEN.START:
		push_error("Not on start screen!")
	
	if toggle:
		titleText.hide()
		titleButtons.hide()
		credits.show()
	else:
		titleText.show()
		titleButtons.show()
		credits.hide()

func _display_race_options(options: Array[RaceOption]):
	if len(trackSelectButtons) < len(options):
		for i in range(len(trackSelectButtons), len(options)):
			var button = Button.new()
			trackSelectButtons.append(button)
			raceOptionsParent.add_child(button)
	for i in range(len(trackSelectButtons)):
		if i < len(options):
			trackSelectButtons[i].text = options[i].name
			trackSelectButtons[i].pressed.connect(_race_option_selected.bind(options[i]))
		else:
			trackSelectButtons[i].hide()

func _race_option_selected(option : RaceOption):
	gameManager.set_race_option(option)
	_switch_screen(SCREEN.CAR_SELECT)

func _display_car_options():
	if len(carSelectButtons) < len(cars):
		for i in range(len(carSelectButtons), len(cars)):
			var button = Button.new()
			carSelectButtons.append(button)
			carOptionsParent.add_child(button)
	for i in range(len(carSelectButtons)):
		if i < len(cars):
			carSelectButtons[i].text = cars[i].model
			carSelectButtons[i].pressed.connect(_car_selected.bind(cars[i]))
		else:
			carSelectButtons[i].hide()

func _car_selected(car: CarData):
	gameManager.set_car(car)

func _start_game():
	gameManager.start_game()
	gameDirector.remove_scene(self)
