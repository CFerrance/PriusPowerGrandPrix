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
@export var title_text: Control
@export var background : TextureRect
@export var title_buttons: Control
@export var options_menu: Control
@export var credits: Control
@export var race_options_parent: Control
@export var start_screen: Control
@export var mode_select_screen: Control
@export var track_select_screen: Control
@export var car_select_screen: Control
@export var car_select: CarouselSelect
@export var color_select: CarouselSelect

@export_category("Assets")
@export var start_background: Texture2D
@export var selection_background: Texture2D
@export var available_colors: Array[CarPalette]

#variables
var current_screen: Screen = Screen.START
var track_select_buttons: Array[Button] = []
var car_select_buttons: Array[Button] = []
var selected_race_type: GameManager.RaceType
var selected_race_option: RaceOption
var selected_car: CarData
var selected_color: CarPalette

#dependencies
var game_manager: GameManager


func bind_dependencies(manager: GameManager) -> void:
	game_manager = manager
	setup()


func setup() -> void:
	selected_car = car_select.get_default() as CarData
	car_select.on_carousel_update.connect(_car_selected)
	
	selected_color = color_select.get_default() as CarPalette
	color_select.on_carousel_update.connect(_color_selected)
	
	#if playing with controller, focus on play button
	if Input.get_connected_joypads():
		var play_button: Control = title_buttons.get_child(0) as Control
		play_button.grab_focus.call_deferred()


#region ui button connections 
func _on_play_button_pressed() -> void:
	_switch_screen(Screen.MODE_SELECT)


func _on_tutorial_button_pressed() -> void:
	selected_race_type = GameManager.RaceType.TUTORIAL
	game_manager.start_tutorial()


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


func _on_cup_button_pressed() -> void:
	selected_race_type = GameManager.RaceType.CUP
	_switch_screen(Screen.TRACK_SELECT)


func _on_practice_button_pressed() -> void:
	selected_race_type = GameManager.RaceType.PRACTICE
	_switch_screen(Screen.TRACK_SELECT)


func _on_mode_select_back_button_pressed() -> void:
	_switch_screen(Screen.START)


func _on_track_select_back_button_pressed() -> void:
	_switch_screen(Screen.MODE_SELECT)


func _on_ready_button_pressed() -> void:
	_try_start_game()


func _on_car_select_back_button_pressed() -> void:
	_switch_screen(Screen.TRACK_SELECT)

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
			if Input.get_connected_joypads():
				var play_button: Control = title_buttons.get_child(0) as Control
				play_button.grab_focus.call_deferred()
		
		Screen.MODE_SELECT:
			_set_background(start_background)
			mode_select_screen.show()
			if Input.get_connected_joypads():
				var play_button: Control = mode_select_screen.get_child(0).get_child(0) as Control
				play_button.grab_focus.call_deferred()
		
		Screen.TRACK_SELECT:
			_set_background(selection_background)
			track_select_screen.show()
			if selected_race_type == GameManager.RaceType.CUP:
				_display_race_options(game_manager.get_cup_options())
			else:
				_display_race_options(game_manager.get_track_options())
			if Input.get_connected_joypads():
				var option: Control = race_options_parent.get_child(0) as Control
				option.grab_focus.call_deferred()
		
		Screen.CAR_SELECT:
			_set_background(selection_background)
			car_select_screen.show()
			if Input.get_connected_joypads():
				car_select.grab_focus.call_deferred()


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
			if track_select_buttons[i].pressed.is_connected(_race_option_selected):
				track_select_buttons[i].pressed.disconnect(_race_option_selected)
			track_select_buttons[i].pressed.connect(_race_option_selected.bind(options[i]))
			track_select_buttons[i].show()
		else:
			track_select_buttons[i].hide()


func _race_option_selected(option : RaceOption) -> void:
	selected_race_option = option
	_switch_screen(Screen.CAR_SELECT)


func _car_selected(car: CarData) -> void:
	selected_car = car


func _color_selected(color: CarPalette) -> void:
	selected_color = color


func _try_start_game() -> void:
	if selected_race_type != null and selected_race_option != null and selected_car != null:
		selections_completed.emit(selected_race_type, selected_race_option, selected_car, selected_color)
