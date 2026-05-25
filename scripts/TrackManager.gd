class_name TrackManager extends Node

@export var startGate: StartGate
@export var gatesDefault: Array[Gate]

@onready var panHandler := $PanHandler

var lapCount: int
var gates: Array[Gate]
var trackerEnabled := false

signal onPlayerFinished

func set_laps(laps: int):
	lapCount = laps

func set_mirror_mode(mirror: bool):
	gates = gatesDefault
	if mirror:
		startGate.rotation_degrees += 180
		gates.reverse()

func position_cars(cars: Array[Car]):
	startGate.assign_starts(cars)

func attach_lap_data(cars: Array[Car]):
	for car in cars:
		var lapData = LapData.new(self, car)
		car.attach_lap_data(lapData)
		lapData.lapUpdate.connect(on_lap_update)
		lapData.raceCompleted.connect(on_race_completed.bind(car))

func flyby():
	await panHandler.handle_flyby()

func on_lap_update():
	pass

func on_race_completed(car: Car):
	if car is PlayerCarController:
		print("You finished the race!")
		onPlayerFinished.emit()
	pass

func toggle_lap_tracker(toggle: bool):
	trackerEnabled = toggle
