class_name RacingUI extends Control

@onready var speedText = $SpeedText
@onready var gearText = $GearText
@onready var placeText = $PlaceText
@onready var lapText = $"Lap Text"

var player: PlayerCarController
var trackManager: TrackManager

func connect_to_track_manager(trackManager: TrackManager):
	self.trackManager = trackManager
	_set_gear(0)
	lapText.text = str(1) + "/" + str(trackManager.lapCount)

func connect_to_player(player: PlayerCarController):
	self.player = player
	player.gearChange.connect(_set_gear)
	player.lapData.lapUpdate.connect(_on_lap_update)

func _process(delta):
	_set_speed(player.get_speed())

func _set_speed(speed):
	speedText.text = str(int(round(speed)))

func _set_gear(gear):
	if gear == 0:
		gearText.text = "ECO"
	elif gear == 1:
		gearText.text = "NORMAL"
	else:
		gearText.text = "POWER"

func _on_lap_update():
	var laps = clampi(len(player.lapData.completedLaps) + 1, 1, trackManager.lapCount)
	lapText.text = str(laps) + "/" + str(trackManager.lapCount)

func _update_lap_and_place(places, data):
	var place = places.find(player.teamName)
	placeText.text = str(place + 1)
	lapText.text = str(data[player].completedLaps + 1)
