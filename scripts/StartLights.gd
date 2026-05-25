class_name StartLights extends Control

@export var lightInterval: float
@export var minWait: float
@export var maxWait: float
@export var lights: Array[Control]

func handle_lights():
	for i in range(0, len(lights)):
		await  get_tree().create_timer(lightInterval).timeout
		lights[i].show()
	
	var rng = RandomNumberGenerator.new()
	await get_tree().create_timer(rng.randf_range(minWait, maxWait)).timeout
	
	for l in lights:
		l.hide()
