class_name TutorialContext extends Node

#dependencies
var game_manager: GameManager


func bind_dependencies(manager: GameManager) -> void:
	game_manager = manager
	
	setup()


func setup() -> void:
	var driving_school_packed: PackedScene = load("res://Tracks/Track_Scenes/DrivingSchool.tscn")
	var driving_school: Node = driving_school_packed.instantiate()
	add_child(driving_school)
