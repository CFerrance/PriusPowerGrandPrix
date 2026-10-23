class_name Credits extends Control

signal scroll_finished

@export var scroll_container: ScrollContainer
@export var margin_container: MarginContainer
@export var rich_text: RichTextLabel
@export var skip_prompt: Label

var scroll_tween: Tween
var skip_prompt_displayed: bool

const SCROLL_SPEED: float = 120.0


func start_scroll() -> void:
	var window_height: int = int(get_viewport_rect().size.y)
	margin_container.add_theme_constant_override("margin_top", window_height)
	margin_container.add_theme_constant_override("margin_bottom", window_height)
	
	scroll_container.scroll_vertical = 0
	skip_prompt_displayed = false
	skip_prompt.self_modulate.a = 0.0
	await get_tree().create_timer(0.5).timeout
	
	# Force Godot to calculate the updated size after margins are added
	await get_tree().process_frame
	
	var total_scroll: int = int(margin_container.get_combined_minimum_size().y - scroll_container.size.y)
	var scroll_duration: float = total_scroll / SCROLL_SPEED
	
	if scroll_tween:
		scroll_tween.kill()
	scroll_tween = create_tween()
	scroll_tween.tween_property(scroll_container, "scroll_vertical", total_scroll, scroll_duration)
	scroll_tween.finished.connect(_on_scroll_finished)


func _on_scroll_finished() -> void:
	if scroll_tween:
		scroll_tween.kill()
	scroll_finished.emit()


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_anything_pressed():
		if skip_prompt_displayed:
			_on_scroll_finished()
		else:
			skip_prompt_displayed = true
			var fade_tween: Tween = create_tween()
			fade_tween.tween_property(skip_prompt, "self_modulate:a", 1.0, 0.5)
