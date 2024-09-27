extends Node

# Fetches node relative to current scene
func current(t: String) -> Node:
    return get_tree().get_current_scene().get_node(t)
