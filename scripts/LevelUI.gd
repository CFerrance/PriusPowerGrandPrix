class_name LevelUI extends Node

#signals
signal continue_pressed

#exports
@export_category("HUD")
@export var hud_parent: Control
@export var speed_text: Label
@export var gear_text: Label
@export var place_text: Label
@export var lap_text: Label
@export var race_timer_text: Label
@export var lap_timer_text: Label

@export_category("Level Start")
@export var level_name: Label
@export var light_interval: float
@export var min_wait: float
@export var max_wait: float
@export var lights: Array[Control]

@export_category("Podium")
@export var podium_parent: Control

@export_category("Standings")
@export var standings_parent: Control

@export_category("Practice Report")
@export var report_parent: Control
@export var final_time_text: Label
@export var best_lap_text: Label
@export var average_lap_text: Label

@export_category("Other")
@export var continue_button: Button

#dependencies
var level_manager: LevelManager
var player: PlayerCarController
var track_manager: TrackManager


func bind_dependencies(l_manager: LevelManager, player_: PlayerCarController, t_manager: TrackManager) -> void:
	level_manager = l_manager
	player = player_
	track_manager = t_manager
	
	lap_text.text = str(1) + "/" + str(track_manager.get_lap_count())
	
	player.gear_changed.connect(_set_gear)
	_set_gear(0)
	player.lap_completed.connect(_on_lap_completed)


func _process(_delta: float) -> void:
	_set_speed_text(player.get_speed_cosmetic())
	if level_manager.is_racing_enabled():
		_update_lap_time()


#region hud
func toggle_hud(toggle: bool) -> void:
	if toggle:
		hud_parent.show()
	else:
		hud_parent.hide()


func _set_speed_text(speed: float) -> void:
	speed_text.text = str(roundi(speed))


func _update_lap_time() -> void:
	race_timer_text.text = Utils.msec_to_time_string(Time.get_ticks_msec() - level_manager.get_race_start())
	lap_timer_text.text = Utils.msec_to_time_string(player.get_lap_time_msec())


func _set_gear(gear: int) -> void:
	if gear == 0:
		gear_text.text = "ECO"
	elif gear == 1:
		gear_text.text = "NORM."
	else:
		gear_text.text = "POWER"


func _on_lap_completed() -> void:
	print("Lap Completed!")
	lap_text.text = str(player.get_laps_completed() + 1) + "/" + str(track_manager.get_lap_count())
#endregion


func set_level_name(race_name: String) -> void:
	level_name.text = race_name


func toggle_level_name(toggle: bool) -> void:
	if toggle:
		level_name.show()
	else:
		level_name.hide()


func handle_start_lights() -> void:
	for i: int in range(0, len(lights)):
		await  get_tree().create_timer(light_interval).timeout
		lights[i].show()
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	await get_tree().create_timer(rng.randf_range(min_wait, max_wait)).timeout
	
	for l: Control in lights:
		l.hide()


func populate_podium(standings: StandingsTracker) -> void:
	
	pass


func toggle_podium(toggle: bool) -> void:
	if toggle:
		podium_parent.show()
		continue_button.show()
	else:
		podium_parent.hide()


func toggle_standings(toggle: bool) -> void:
	if toggle:
		standings_parent.show()
		continue_button.show()
	else:
		standings_parent.hide()


func toggle_practice_stats(toggle: bool) -> void:
	if toggle:
		report_parent.show()
		continue_button.show()
		final_time_text.text = player.get_final_time_string()
		best_lap_text.text = player.get_best_lap_time_string()
		average_lap_text.text = player.get_average_lap_time_string()
	else:
		report_parent.hide()


func _on_continue_button_pressed() -> void:
	continue_pressed.emit()
