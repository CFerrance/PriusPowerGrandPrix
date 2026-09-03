class_name StartGate extends Gate

#exports
@export var start_positions: Array[Node2D]


func assign_starts(cars: Array[Car]) -> void:
	for i: int in range(len(cars)):
		cars[i].position = start_positions[i].global_position
		cars[i].rotation = start_positions[i].global_rotation
