extends ProgressBar


func _ready():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		player.big_echo_used.connect(_on_big_echo_used)
		
func _on_big_echo_used(time):
	max_value = time
	value = 0.0
	
	var tween = create_tween()
	tween.tween_property(self, "value", time, time)
