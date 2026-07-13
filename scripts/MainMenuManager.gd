class_name MainMenuManager extends Node

#signals
signal selections_completed(race_type: GameManager.RaceType, race_option: RaceOption, car_choice: CarData)

#enums
enum Screen {
	START,
	MODE_SELECT,
	TRACK_SELECT,
	CAR_SELECT
}

#exports
@export_category("References")
@export var background : TextureRect
@export var title_text: Control
@export var title_buttons: Control
@export var options_menu: Control
@export var credits: Control
@export var race_options_parent: Control
@export var car_options_parent: Control
@export var start_screen: Control
@export var mode_select_screen: Control
@export var track_select_screen: Control
@export var car_select_screen: Control

@export_category("Data")
@export var tracks: Array[RaceOption]
@export var prix_options: Array[RaceOption]
@export var cars: Array[CarData]

@export_category("Assets")
@export var start_background: Texture2D
@export var selection_background: Texture2D

#variables
var current_screen: Screen = Screen.START
var track_select_buttons: Array[Button] = []
var car_select_buttons: Array[Button] = []
var selected_race_type: GameManager.RaceType
var selected_race_option: RaceOption
var selected_car: CarData

#dependencies
var game_manager: GameManager

func bind_dependencies(manager: GameManager) -> void:
	game_manager = manager

func _ready() -> void:
	pass

#region ui button connections 
func _on_play_button_pressed() -> void:
	_switch_screen(Screen.MODE_SELECT)


func _on_options_button_pressed() -> void:
	_toggle_options_menu(true)


func _on_credits_button_pressed() -> void:
	_toggle_credits(true)


func _on_quit_button_pressed() -> void:
	game_manager.request_quit()


func _on_options_back_button_pressed() -> void:
	_toggle_options_menu(false)


func _on_single_button_pressed() -> void:
	selected_race_type = GameManager.RaceType.SINGLE
	_switch_screen(Screen.TRACK_SELECT)


func _on_prix_button_pressed() -> void:
	selected_race_type = GameManager.RaceType.PRIX
	_switch_screen(Screen.TRACK_SELECT)


func _on_practice_button_pressed() -> void:
	selected_race_type = GameManager.RaceType.PRACTICE
	_switch_screen(Screen.TRACK_SELECT)


func _on_ready_button_pressed() -> void:
	_try_start_game()
#endregion


func _switch_screen(new_screen: Screen) -> void:
	current_screen = new_screen
	
	start_screen.hide()
	mode_select_screen.hide()
	track_select_screen.hide()
	car_select_screen.hide()
	
	match new_screen:
		Screen.START:
			_set_background(start_background)
			start_screen.show()
		Screen.MODE_SELECT:
			_set_background(start_background)
			mode_select_screen.show()
		Screen.TRACK_SELECT:
			_set_background(selection_background)
			track_select_screen.show()
			if selected_race_type == GameManager.RaceType.PRIX:
				_display_race_options(prix_options)
			else:
				_display_race_options(tracks)
		Screen.CAR_SELECT:
			_set_background(selection_background)
			car_select_screen.show()
			_display_car_options()


func _set_background(bg: Texture2D) -> void:
	background.texture = bg


func _toggle_options_menu(toggle: bool) -> void:
	if current_screen != Screen.START:
		push_error("Not on start screen!")
	
	if toggle:
		title_text.hide()
		title_buttons.hide()
		options_menu.show()
	else:
		title_text.show()
		title_buttons.show()
		options_menu.hide()


func _toggle_credits(toggle: bool) -> void:
	if current_screen != Screen.START:
		push_error("Not on start screen!")
	
	if toggle:
		title_text.hide()
		title_buttons.hide()
		credits.show()
	else:
		title_text.show()
		title_buttons.show()
		credits.hide()


func _display_race_options(options: Array[RaceOption]) -> void:
	if len(track_select_buttons) < len(options):
		for i: int in range(len(track_select_buttons), len(options)):
			var button: Button = Button.new()
			track_select_buttons.append(button)
			race_options_parent.add_child(button)
	for i: int in range(len(track_select_buttons)):
		if i < len(options):
			track_select_buttons[i].text = options[i].name
			track_select_buttons[i].pressed.connect(_race_option_selected.bind(options[i]))
		else:
			track_select_buttons[i].hide()


func _race_option_selected(option : RaceOption) -> void:
	selected_race_option = option
	_switch_screen(Screen.CAR_SELECT)


func _display_car_options() -> void:
	if len(car_select_buttons) < len(cars):
		for i: int in range(len(car_select_buttons), len(cars)):
			var button: Button = Button.new()
			car_select_buttons.append(button)
			car_options_parent.add_child(button)
	for i: int in range(len(car_select_buttons)):
		if i < len(cars):
			car_select_buttons[i].text = cars[i].model
			car_select_buttons[i].pressed.connect(_car_selected.bind(cars[i]))
		else:
			car_select_buttons[i].hide()


func _car_selected(car: CarData) -> void:
	selected_car = car


func _try_start_game() -> void:
	if selected_race_type != null and selected_race_option != null and selected_car != null:
		selections_completed.emit(selected_race_type, selected_race_option, selected_car)
