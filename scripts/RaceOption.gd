class_name RaceOption extends Resource

@export var name: String:
	get: return name

@export var tracks: Array[PackedScene]:
	get: return tracks

@export_multiline var description: String:
	get: return description
