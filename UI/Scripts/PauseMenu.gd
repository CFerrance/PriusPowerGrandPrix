class_name PauseMenu extends CanvasLayer

#exports
@export var resume_button: Button
@export var restart_button: Button

#dependencies
var game_manager: GameManager
var level_manager: LevelManager


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func bind_dependencies(game: GameManager, level: LevelManager) -> void:
	game_manager = game
	level_manager = level


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("Pause"):
		toggle_pause()


func toggle_pause() -> void:
	if get_tree().paused == false:
		get_tree().paused = true
		
		var race_type: GameManager.RaceType = game_manager.get_race_type()
		if race_type == GameManager.RaceType.PRACTICE or race_type == GameManager.RaceType.TUTORIAL:
			restart_button.show()
		else:
			restart_button.hide()
		
		if Input.get_connected_joypads():
			restart_button.grab_focus.call_deferred()
		
		show()
	
	else:
		get_tree().paused = false
		hide()


func toggle_options(toggle: bool) -> void:
	#TODO Implement options in pause menu
	print("TODO: Options menu in pause menu")


#region button connections
func _resume_button_pressed() -> void:
	toggle_pause()


func _options_button_pressed() -> void:
	toggle_options(true)


func _restart_button_pressed() -> void: 
	get_tree().paused = false
	game_manager.request_level_restart()


func _quit_to_menu_button_pressed() -> void:
	get_tree().paused = false
	level_manager.request_quit_to_menu()


func _quit_button_pressed() -> void:
	get_tree().paused = false
	level_manager.request_quit()

#endregion
