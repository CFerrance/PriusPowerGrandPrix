@abstract
class_name GameContext extends Node

var game_manager: GameManager


func bind_dependencies(g_manager: GameManager) -> void:
	game_manager = g_manager


func request_quit() -> void:
	game_manager.request_quit()
