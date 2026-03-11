@tool
extends StaticBody2D

# Экспортируем параметры, чтобы они были в Инспекторе
@export var width: float = 100.0:
	set(value):
		width = value
		update_shape()

@export var height: float = 100.0:
	set(value):
		height = value
		update_shape()

# Тип треугольника: Равнобедренный (Isosceles) или Прямоугольный (Right)
@export_enum("Isosceles", "Right-angled") var triangle_type: int = 0:
	set(value):
		triangle_type = value
		update_shape()

func _ready():
	# Чтобы коллизия создалась сразу при перетаскивании в сцену
	update_shape()

func update_shape():
	# Ищем ребенка, если он еще не готов (нужно для работы @tool)
	var poly = get_node_or_null("CollisionPolygon2D")
	if not poly:
		return
		
	var points = PackedVector2Array()
	
	if triangle_type == 0: # Равнобедренный (центр в 0,0)
		points = PackedVector2Array([
			Vector2(0, -height / 2),
			Vector2(width / 2, height / 2),
			Vector2(-width / 2, height / 2)
		])
	else: # Прямоугольный (левый нижний угол в 0,0)
		points = PackedVector2Array([
			Vector2(0, 0),
			Vector2(width, 0),
			Vector2(0, -height)
		])
	
	poly.polygon = points
