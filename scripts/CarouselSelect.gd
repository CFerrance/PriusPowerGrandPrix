class_name CarouselSelect extends Button

#signals
signal on_carousel_update(selected: Resource)

#vars
var selected: int = 0

#export
@export var options: Array[Resource]


func _ready() -> void:
	disabled = true
	self.text = get_default().resource_name


func get_default() -> Resource:
	return options[0]


func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		previous_option()
		self.text = options[selected].resource_name
		accept_event()
	elif  event.is_action_pressed("ui_right"):
		next_option()
		self.text = options[selected].resource_name
		accept_event()


func previous_option() -> void:
	selected = wrapi(selected - 1, 0, len(options))
	on_carousel_update.emit(options[selected])


func next_option() -> void:
	selected = wrapi(selected + 1, 0, len(options))
	on_carousel_update.emit(options[selected])
