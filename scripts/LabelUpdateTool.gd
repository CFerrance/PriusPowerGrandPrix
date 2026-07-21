@tool
extends Node2D

@export var display_text: String:
	set(new_text):
		display_text = new_text
		_update_label(display_text)

@onready var label: Label = $Label


func _ready() -> void:
	_update_label(display_text)


func _update_label(text: String) -> void:
	if is_inside_tree() and label:
		label.text = text
