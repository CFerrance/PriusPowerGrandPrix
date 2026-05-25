class_name PanHandler extends Node

@export var panSpeed: float
@export var panPaths: Array[PathFollow2D] = []

@onready var panCam: Camera2D = $PanCam

var currentPath: int
var currentProgress: float

func handle_flyby():
	panCam.enabled = true
	currentPath = 0
	currentProgress = 0
	while true:
		if currentPath >= len(panPaths):
			panCam.enabled = false
			return
		currentProgress += get_process_delta_time() * panSpeed
		panPaths[currentPath].progress = currentProgress
		panCam.transform = panPaths[currentPath].transform
		if panPaths[currentPath].progress_ratio >= 1.0:
			currentPath += 1
			currentProgress = 0
		await get_tree().process_frame
