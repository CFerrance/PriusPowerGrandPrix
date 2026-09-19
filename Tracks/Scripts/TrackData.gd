class_name TrackData extends RaceOption

#exports
@export var scene: PackedScene
@export_multiline var description: String


func get_race_queue() -> Array[TrackData]:
	var queue: Array[TrackData] = [self]
	return queue
