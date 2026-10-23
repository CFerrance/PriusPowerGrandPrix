class_name Fader extends ColorRect

var fade_tween: Tween


func fade_to_black(duration: float) -> void:
	show()
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(self, "color:a", 1.0, duration)
	await fade_tween.finished


func fade_in(duration: float) -> void:
	if fade_tween:
		fade_tween.kill()
	
	fade_tween = create_tween()
	fade_tween.tween_property(self, "color:a", 0.0, duration)
	fade_tween.tween_callback(hide)


func is_active() -> bool:
	if fade_tween == null:
		return false
	return (fade_tween.is_running())
