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


func _ready() -> void:
	_update_barrier_text(barrier_text)
	_update_sprite_art(barrier_art)


func _update_barrier_text(text: String) -> void:
	if not is_inside_tree():
		return
	
	var label: Label = get_node_or_null("Sprite2D/Label")
	
	if label == null:
		return
	
	label.text = text


func _update_sprite_art(texture: Texture2D) -> void:
	if not is_inside_tree() or texture == null:
		return
	
	var sprite: Sprite2D = get_node_or_null("Sprite2D")
	var label: Label = get_node_or_null("Sprite2D/Label")
	var collision_shape: CollisionShape2D = get_node_or_null("Sprite2D/StaticBody2D/CollisionShape2D")
	
	if sprite == null or label == null or collision_shape == null:
		return
	
	sprite.texture = texture
	label.position.x = sprite.position.x - texture.get_width() / 2.0
	label.position.y = sprite.position.y - texture.get_height() / 2.
	
	var capsule: CapsuleShape2D = collision_shape.shape as CapsuleShape2D
	capsule.height = texture.get_width() - 10.0
