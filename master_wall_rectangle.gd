@tool
extends StaticBody2D


@export var rect_size: Vector2 = Vector2(100, 100):
	set(new_value):
		rect_size = new_value
		_update_wall()

var collider: CollisionShape2D

func _ready():
	_update_wall()

func _update_wall():
	if not collider:
		collider = get_node_or_null("Collider")
	
	if not collider:
		return
	
	if collider and collider.shape:
		collider.shape = collider.shape.duplicate()
		
	if collider.shape is RectangleShape2D:
		collider.shape.size = rect_size
	
