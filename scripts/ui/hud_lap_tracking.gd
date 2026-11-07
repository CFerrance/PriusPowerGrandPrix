class_name HudLapTracker extends Control

@export var place_text: Label
@export var lap_text: Label
@export var race_timer_text: Label
@export var lap_timer_text: Label

var player_lap_tracker: LapTracker
var lap_count: int


func bind_dependencies(player_tracker: LapTracker) -> void:
	player_lap_tracker = player_tracker
	player_lap_tracker.lap_completed.connect(_on_lap_completed)


func setup(laps: int) -> void:
	lap_count = laps
	lap_text.text = str(1) + "/" + str(lap_count)


func update_lap_time(elapsed_time: float) -> void:
	race_timer_text.text = Utils.sec_to_time_string(elapsed_time)
	lap_timer_text.text = Utils.sec_to_time_string(player_lap_tracker.get_lap_time_sec())


func _on_lap_completed() -> void:
	print("Lap Completed!")
	lap_text.text = str(player_lap_tracker.get_laps_completed() + 1) + "/" + str(lap_count)
