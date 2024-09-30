extends Node

# Fetches node relative to scene
func find(t: String = ".") -> Node:
    return get_tree().get_current_scene().get_node(t)

func engine_time() -> int:
    return Time.get_ticks_msec()
