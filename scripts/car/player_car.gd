class_name PlayerCar extends Car

#exports
@export var player_cam: Camera2D


func toggle_player_camera(toggle: bool) -> void:
	player_cam.enabled = toggle
