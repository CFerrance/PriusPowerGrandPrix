class_name GameDirector extends Node

#constants
const  game_manager_packed: PackedScene = preload("res://Misc/Scenes/GameManager.tscn")

#children
var game_manager: GameManager


func _ready() -> void:
	_build_children()
	_bind_child_dependencies()


func _build_children() -> void:
	game_manager = game_manager_packed.instantiate()
	add_child(game_manager)


func _bind_child_dependencies() -> void:
	game_manager.bind_dependencies(self)


func request_quit() -> void:
	get_tree().quit()
