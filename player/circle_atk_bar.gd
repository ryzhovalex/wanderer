extends ProgressBar


@onready var PLAYER: PlayerChar = get_tree().get_first_node_in_group("@Player")


func _process(delta: float) -> void:
	if PLAYER.circle_atk_last_time == 0:
		value = 1
		return
	
	value = (core.time() - PLAYER.circle_atk_last_time) / float(PLAYER.stat.circle_atk_cooldown)
