class_name Car extends Node2D

#exports
@export var car_controller: CarController
@export var lap_tracker: LapTracker

#variables
var team_name: String


func configure_car(team: String, data: CarData, palette: CarPalette = null) -> void:
	team_name = team
	car_controller.configure_car_controller(data, palette)


func get_car_controller() -> CarController:
	return car_controller


func get_lap_tracker() -> LapTracker: 
	return lap_tracker
