class_name TutorialContext extends GameContext


func setup() -> void:
	var driving_school_packed: PackedScene = load("res://scenes/tracks/driving_school.tscn")
	var tutorial_manager: TutorialManager = driving_school_packed.instantiate()
	add_child(tutorial_manager)
	tutorial_manager.bind_dependencies(self)
