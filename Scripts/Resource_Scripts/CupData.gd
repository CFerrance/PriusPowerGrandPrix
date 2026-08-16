class_name CupData extends RaceOption

#exports
@export var tracks: Array[TrackData]


func get_race_queue() -> Array[TrackData]:
	return tracks.duplicate()
