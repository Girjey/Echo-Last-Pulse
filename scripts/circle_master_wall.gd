@tool
extends StaticBody2D

@export var size: float = 50.0:
	set(new_value):
		size = new_value
		_update_wall()

# Убираем @onready для надежности в @tool режиме
var collider: CollisionShape2D

func _ready():
	_update_wall()

func _update_wall():
	# Если переменная пуста, пытаемся найти узел вручную
	if not collider:
		collider = get_node_or_null("Collider")
	
	# Если узла всё еще нет (например, он еще не создался в дереве)
	if not collider:
		return
	
	if collider.shape == null:
		return
	
	# Убедись, что в инспекторе у Collider выбран CircleShape2D
	if collider.shape is CircleShape2D:
		collider.shape.radius = size
