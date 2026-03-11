extends Node2D
@onready var player = %Player_body
@onready var spawn_point = $Marker2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_player()


func _spawn_player():
	player.position = spawn_point.position
	player.velocity = Vector2.ZERO
