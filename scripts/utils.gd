class_name Utils


static func sec_to_time_string(seconds: float) -> String:
	var minutes: int = int(seconds / 60)
	seconds = fmod(seconds, 60)
	return str(minutes) + ":" + str(seconds).pad_decimals(2).pad_zeros(2)


static func get_cosmetic_speed(speed: float) -> int:
	return int(speed / 10)
