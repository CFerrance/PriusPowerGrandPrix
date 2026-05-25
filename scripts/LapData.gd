class_name LapData

var completedLaps: Array[float]
var passedGates: Array[Gate]

var trackManager: TrackManager

signal lapUpdate
signal raceCompleted

func _init(trackManager: TrackManager, car: Car):
	self.trackManager = trackManager
	car.attach_lap_data(self)

func try_add_gate(gate: Gate):
	if not trackManager.trackerEnabled:
		return
	if _try_add_gate(gate):
		lapUpdate.emit()
		if len(completedLaps) == trackManager.lapCount:
			raceCompleted.emit()

func _try_add_gate(gate: Gate) -> bool:
	if gate == trackManager.startGate:
		if len(completedLaps) == 0 and len(passedGates) == 0:
			passedGates.append(gate)
			return true
		elif len(passedGates) == len(trackManager.gates) + 1:
			completedLaps.append(Time.get_ticks_msec())
			passedGates = []
			passedGates.append(gate)
			return true
		return false
	else:
		if trackManager.gates.find(gate) == len(passedGates) - 1:
			passedGates.append(gate)
			print(len(passedGates))
			return true
		return false
