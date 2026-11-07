class_name TutorialManager extends Node2D

@export var tutorial_car: CarData


func _ready() -> void:
	var player_car_packed: PackedScene = load("res://scenes/cars/player_car.tscn")
	var player_car: PlayerCar = player_car_packed.instantiate()
	player_car.configure_car("Player Team", tutorial_car)
	add_child(player_car)
	
	var tutorial_ui_packed: PackedScene = load("res://scenes/ui/tutorial_ui.tscn")
	var tutorial_ui: TutorialUI = tutorial_ui_packed.instantiate()
	tutorial_ui.toggle_hud(false)
	add_child(tutorial_ui)
	tutorial_ui.setup(player_car)
	
	var pause_menu_packed: PackedScene = load("res://scenes/menus/pause_menu.tscn")
	var pause_menu: PauseMenu = pause_menu_packed.instantiate()
	add_child(pause_menu)


func _on_tutorial_track_portal_body_entered(body: Node2D) -> void:
	if body is PlayerCarController:
		print("TELEPORT")
