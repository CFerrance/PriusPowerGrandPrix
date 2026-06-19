class_name Car extends RigidBody2D

@onready var carSprite := $Sprite

var teamName: String
var carData: Resource
var lapData: LapData

var levelManager : LevelManager

func _ready():
	levelManager = get_tree().get_first_node_in_group("LevelManager")

func configure_car(teamName: String, carData: CarData):
	self.teamName = teamName
	self.carData = carData
	self.mass = carData.mass
	carSprite.texture = carData.sprite

func attach_lap_data(lapData: LapData):
	self.lapData = lapData
	lapData.raceCompleted.connect(on_race_completed)

func on_pit_entry():
	print("Pit Entry!")
	pass

func on_race_completed():
	print("Race Completed!")
