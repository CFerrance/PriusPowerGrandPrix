class_name StartLights extends Control

@export var light_interval: float
@export var min_wait: float
@export var max_wait: float
@export var lights: Array[Control]


func handle_start_lights() -> void:
	show()
	
	for i: int in range(0, len(lights)):
		await  get_tree().create_timer(light_interval, false).timeout
		lights[i].show()
	
	var rng: RandomNumberGenerator = RandomNumberGenerator.new()
	await get_tree().create_timer(rng.randf_range(min_wait, max_wait), false).timeout
	
	for l: Control in lights:
		l.hide()
	
	hide()
