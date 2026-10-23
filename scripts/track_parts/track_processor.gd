class_name TrackProcessor extends PathFollow2D

signal build_completed

@export var interval: float = 200.0

var waypoints: Array[Waypoint] = []

const WAYPOINT: PackedScene = preload("res://scenes/track_parts/waypoint.tscn")


func build_waypoints(waypoints_parent: Node) -> void:
	waypoints.clear()
	
	var path: Path2D = get_parent()
	progress = interval
	while(progress < path.curve.get_baked_length()):
		var wp: Waypoint = WAYPOINT.instantiate()
		wp.global_position = global_position
		wp.rotation_degrees = global_rotation_degrees + 90.0
		waypoints_parent.add_child(wp)
		waypoints.append(wp)
		
		progress += interval
	
	waypoints[0].setup(waypoints[1], waypoints[len(waypoints) - 1], 0)
	waypoints[len(waypoints) - 1].setup(waypoints[0], waypoints[len(waypoints) - 2], len(waypoints) - 1)
	
	for i: int in range(1, len(waypoints) - 1):
		waypoints[i].setup(waypoints[i + 1], waypoints[i - 1], i)
	
	await  get_tree().physics_frame
	build_completed.emit()


func get_first_waypoint() -> Waypoint:
	return waypoints[0]
