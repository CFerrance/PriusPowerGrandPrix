@tool
extends Node2D

#exports
@export_multiline var barrier_text: String:
	set(new_text):
		barrier_text = new_text
		_update_barrier_text(barrier_text)

@export var barrier_art: Texture2D:
	set(new_texture):
		barrier_art = new_texture
		_update_sprite_art(barrier_art)

#onready
@onready var label: Label = $Sprite2D/Label
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	_update_barrier_text(barrier_text)
	_update_sprite_art(barrier_art)


func _update_barrier_text(text: String) -> void:
	if is_inside_tree() and label:
		label.text = text


func _update_sprite_art(texture: Texture2D) -> void:
	if is_inside_tree() and sprite:
		sprite.texture = texture
