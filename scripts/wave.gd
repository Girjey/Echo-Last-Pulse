extends Node2D
@onready var particles = get_tree().get_first_node_in_group("dots_particles")
@export var rays: int = 300
@export var wave_lifetime: float = 1.0
@export var expansion_speed: float = 80.0
@export var width: float = 2.0

var ghost_points: Array = []
@export var ghost_lifetime: float = 3.0
var space_state
var visual_data = []
var dot_alpha
var current_radius: float = 0.0
var color: Color = Color.WHITE
var time_lived: float = 0.0

func _ready() -> void: # однократное использование после инициализации 
	#получили данные 2D мира
	space_state = get_world_2d().direct_space_state

func _physics_process(delta):
	var angle_step = TAU / rays
	
	time_lived += delta
	color.a = lerp(1.0, 0.0, time_lived / wave_lifetime)
	for i in range(ghost_points.size() - 1, -1, -1):
		var point = ghost_points[i]
		point.time -= delta
		if point.time <= 0:
			ghost_points.remove_at(i)
			
	if time_lived >= wave_lifetime:
		visual_data.clear()
		
		if ghost_points.is_empty():
			queue_free()
		queue_redraw()
		return
		
	current_radius += delta * expansion_speed
	
	var current_data = []
	for i in range(rays):
		var angle = i * angle_step
		# посчитали уголки для rays кол-во лучей
		var direction = Vector2(cos(angle), sin(angle)) # направление для каждого луча
		var start_pos = global_position
		var end_pos = start_pos + (direction * current_radius)
		var query = PhysicsRayQueryParameters2D.create(start_pos, end_pos) #задали физическую очередь на отстрел лучей
		query.collision_mask = 1
		var result = space_state.intersect_ray(query) # метод который пускает лучи
		if result:
			var local_hit = to_local(result.position)
			current_data.append({
				"point": to_local(result.position),
				"is_hit": true
			})
			
			if i % 10 == 0:
				ghost_points.append({
				"pos": local_hit,
				"time": ghost_lifetime
				})
		else:
			current_data.append({
				"point": to_local(end_pos),
				"is_hit": false
			})
	if current_data.size() > 0:
		current_data.append(current_data[0])
		visual_data = current_data
		queue_redraw()
	
func _draw():
	for p in ghost_points:
		dot_alpha = p.time / ghost_lifetime
		var draw_color = Color(1, 1, 1, dot_alpha)
		draw_rect(Rect2(p.pos - Vector2(1,1), Vector2(2,2)), Color(1, 1, 1, dot_alpha))
		
	if visual_data.is_empty():
		return
		
	for i in range(visual_data.size() - 1):
		var current = visual_data[i]
		var next = visual_data[i + 1]
		
		if current["is_hit"] != next["is_hit"]:
			continue
		var p1 = current["point"]
		var p2 = next["point"]
		
		if current["is_hit"] and next["is_hit"]:
			if p1.distance_to(p2) < 30.0:
				draw_line(p1, p2, color, width)
			
		if not current["is_hit"] and not next["is_hit"]:
			if p1.distance_to(p2) < 100.0:
				draw_line(p1, p2, color, width)
