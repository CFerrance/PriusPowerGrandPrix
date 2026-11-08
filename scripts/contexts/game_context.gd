@abstract
class_name GameContext extends Context


func request_quit_to_menu() -> void:
	game_manager.request_quit_to_menu()


@abstract func is_restartable() -> bool
@abstract func request_restart() -> void
