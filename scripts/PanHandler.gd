class_name PanHandler extends Node

#exports
@export var pan_speed: int = 900
@export var pan_paths: Array[PathFollow2D] = []

#vars
var current_path: int
var current_progress: float

#onready
@onready var pan_cam: Camera2D = $PanCam

func handle_flyby() -> void:
	pan_cam.enabled = true
	current_path = 0
	current_progress = 0
	while true:
		if current_path >= len(pan_paths):
			pan_cam.enabled = false
			return
		current_progress += get_process_delta_time() * pan_speed
		pan_paths[current_path].progress = current_progress
		pan_cam.transform = pan_paths[current_path].transform
		if pan_paths[current_path].progress_ratio >= 1.0:
			current_path += 1
			current_progress = 0
		await get_tree().process_frame
