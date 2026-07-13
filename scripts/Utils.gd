class_name Utils


static func msec_to_time_string(msec: float) -> String:
	var seconds: float = msec / 1000.0
	var minutes: int = int(seconds / 60)
	seconds = fmod(seconds, 60)
	return str(minutes) + ":" + str(seconds).pad_decimals(2).pad_zeros(2)
