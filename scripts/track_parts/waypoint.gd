class_name Waypoint extends Node2D

@export var right_cast: RayCast2D
@export var left_cast: RayCast2D
@export var label: Label

var number: int = 0

var next_waypoint: Waypoint
var prev_waypoint: Waypoint


func setup(next: Waypoint, prev: Waypoint, num: int) -> void:
	next_waypoint = next
	prev_waypoint = prev
	number = num
	
	label.text = var_to_str(number)
