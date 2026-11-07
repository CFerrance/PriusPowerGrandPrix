@abstract
class_name CarController extends RigidBody2D

signal on_gate_passed

@export var car_sprite: Sprite2D
@export var collider: CollisionShape2D
@export var brake_light: PointLight2D

var car_data: CarData


func configure_car_controller(data: CarData, palette: CarPalette = null) -> void:
	car_data = data
	
	car_sprite.texture = data.sprite
	
	if palette:
		car_sprite.material = car_sprite.material.duplicate()
		var shader_material: ShaderMaterial = car_sprite.material as ShaderMaterial
		shader_material.set_shader_parameter("replacement_palette", palette.palette)
	
	self.mass = car_data.mass
	collider.position.y = car_data.collider_offset
	var collision_shape: CapsuleShape2D = collider.shape as CapsuleShape2D
	collision_shape.height = car_data.collider_height
	collision_shape.radius = car_data.collider_radius


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("gate"):
		on_gate_passed.emit(body)
