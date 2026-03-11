extends CharacterBody2D

@export var walking_speed: float = 80.0
@export var sprint_speed: float = 150.0
@export var echo_scene_packed: PackedScene
@export var sound_walk: AudioStream
@export var clap_sound: AudioStream
@onready var camera = $Camera2D
signal big_echo_used(time)
var can_echo_space: bool = true

#передвижение
var current_speed: float
var last_position = Vector2.ZERO
var total_distance: float
#камера
var sprinting_zoom = Vector2(2.5, 2.5)
var walking_zoom = Vector2(2.0, 2.0)
var target_zoom = Vector2()

# словари
@onready var walk_params = {
"expansion_speed": 80.0,
"wave_lifetime": 1.0,
"sound": sound_walk,
"pitch": 1.0,
"volume_db": 0
}

@onready var sprint_params = {
"expansion_speed": 150.0,
"wave_lifetime": 0.5,
"sound": sound_walk,
"pitch": 1.1,
"volume_db": 5
}

@onready var space_params = {
"expansion_speed": 200.0,
"wave_lifetime": 2.0,
"sound": clap_sound,
"pitch": 0.7,
"volume_db": 5
}
func _ready():
	last_position = position
	
func _physics_process(delta):
	var direction = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	var is_trying_to_sprint = Input.is_action_pressed("shift_action")
	
	
	var is_sprinting = false
	if direction != Vector2.ZERO and is_trying_to_sprint:
		is_sprinting = true
	else:
		is_sprinting = false
		
	if is_sprinting:
		current_speed = sprint_speed
		target_zoom = sprinting_zoom
	else:
		current_speed = walking_speed
		target_zoom = walking_zoom
		
	var current_echo_params = sprint_params if is_sprinting else walk_params
	var step_distance = 50.0 if is_sprinting else 70.0
	
	velocity = direction * current_speed
	move_and_slide()
	
	camera.zoom = camera.zoom.lerp(target_zoom, 5.0 * delta)
	
	total_distance += position.distance_to(last_position)
	last_position = position
	
	if total_distance >= step_distance:
		spawn_echo(current_echo_params)
		total_distance = 0
	
func _input(event):
	if event.is_action_pressed("space_action") and can_echo_space:
		spawn_echo(space_params)
		flash_abberation()
		start_echo_space_cooldown()
		
		big_echo_used.emit(3.0)
	
func spawn_echo(params: Dictionary):
		var echo_scene = echo_scene_packed.instantiate()
		get_parent().add_child(echo_scene)
		echo_scene.global_position = global_position
		
		var sfx = echo_scene.get_node("PlaySound")
		
		sfx.stream = params["sound"]
		sfx.pitch_scale = params["pitch"]
		sfx.volume_db = params["volume_db"]
		
		echo_scene.expansion_speed = params["expansion_speed"]
		echo_scene.wave_lifetime = params["wave_lifetime"]
		sfx.play()
		
func start_echo_space_cooldown():
	can_echo_space = false
	await get_tree().create_timer(3.0).timeout
	can_echo_space = true
	
func flash_abberation():
	var fx_rect = get_tree().get_first_node_in_group("PostProcessing")
	
	if fx_rect and fx_rect.material:
		var tween = create_tween()
		tween.tween_property(fx_rect.material, "shader_parameter/chromatic_intensity", 0.04, 0.1)
		tween.tween_property(fx_rect.material, "shader_parameter/chromatic_intensity", 0.0, 0.8)
