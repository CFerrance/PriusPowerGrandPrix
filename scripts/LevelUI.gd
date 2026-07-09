class_name LevelUI extends Node

#exports
@export_category("HUD")
@export var hud_parent: Control
@export var speed_text: Label
@export var gear_text: Label
@export var place_text: Label
@export var lap_text: Label
@export var race_timer_text: Label
@export var lap_timer_text: Label

@export_category("Start Lights")
@export var light_interval: float
@export var min_wait: float
@export var max_wait: float
@export var lights: Array[Control]

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
	_set_speed_text(player.get_speed())
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
	var race_time_sec: float = (Time.get_ticks_msec() - level_manager.get_race_start()) / 1000.0
	var race_time_min: int = int(race_time_sec / 60) 
	race_time_sec = fmod(race_time_sec, 60)
	race_timer_text.text = str(race_time_min) + ":" + str(race_time_sec).pad_decimals(2).pad_zeros(2)
	
	var lap_time_sec: float = player.get_lap_time_sec()
	var lap_time_min: int = int(lap_time_sec / 60)
	lap_time_sec = fmod(lap_time_sec, 60)
	lap_timer_text.text = str(lap_time_min) + ":" + str(lap_time_sec).pad_decimals(2).pad_zeros(2)

func _set_gear(gear: int) -> void:
	if gear == 0:
		gear_text.text = "ECO"
	elif gear == 1:
		gear_text.text = "NORMAL"
	else:
		gear_text.text = "POWER"


func _on_lap_completed() -> void:
	print("Lap Completed!")
	lap_text.text = str(player.get_laps_completed()) + "/" + str(track_manager.get_lap_count())
#endregion

func handle_start_lights() -> void:
	for i: int in range(0, len(lights)):
		await  get_tree().create_timer(light_interval).timeout
		lights[i].show()
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	await get_tree().create_timer(rng.randf_range(min_wait, max_wait)).timeout
	
	for l: Control in lights:
		l.hide()
