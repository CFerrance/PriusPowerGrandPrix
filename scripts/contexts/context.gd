@abstract
class_name Context extends Node

#dependencies
var game_manager: GameManager


func bind_dependencies(game_manager_: GameManager) -> void:
	game_manager = game_manager_


func request_quit() -> void:
	game_manager.request_quit()
