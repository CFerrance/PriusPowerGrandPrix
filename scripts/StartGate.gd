class_name StartGate extends Gate

@export var startPositions: Array[Node2D]

func assign_starts(cars: Array[Car]):
	for i in range(len(cars)):
		cars[i].position = startPositions[i].global_position
		cars[i].rotation = startPositions[i].global_rotation
