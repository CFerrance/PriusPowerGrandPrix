class_name StandingsTracker

#variables
var car_order: Array[Car]


func _init(cars: Array[Car]) -> void:
	for car: Car in cars:
		car.gate_passed.connect(on_car_advance)
	car_order = cars.duplicate()


func on_car_advance() -> void:
	car_order.sort_custom(_sort_cars)


func get_car_position(car: Car) -> int:
	var pos: int = car_order.find(car)
	assert(pos != -1)
	return pos


func _sort_cars(a: Car, b: Car) -> bool:
	var lap_dif: int = a.get_laps_completed() - b.get_laps_completed()
	if lap_dif != 0:
		return lap_dif > 0
	
	var gate_dif: int = a.get_gates_this_lap() != b.get_gates_this_lap()
	if gate_dif != 0:
		return gate_dif > 0
		
	return a.get_last_gate_msec() < b.get_last_gate_msec()
