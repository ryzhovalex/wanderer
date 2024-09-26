extends Node2D

# How often to call spawn instruction
@export var period_ms: float = 1000
# @export var spawned: Array[PackedScene]
@export var tester: PackedScene

var last_spawned_ms: float = 0

func _process(_delta):
    var current_ms := Time.get_ticks_msec()
    if current_ms - last_spawned_ms > period_ms:
        last_spawned_ms = current_ms
        # var chosen = spawned.pick_random()
        var chosen := tester
        if chosen == null:
            printerr("No content in `spawned` array")
            return
        var chosen_created := chosen.instantiate()

        var visible_size := get_viewport().get_visible_rect().size
        var rand_gen := RandomNumberGenerator.new()
        var rand_x := rand_gen.randf_range(0, visible_size.x)
        var rand_y := rand_gen.randf_range(0, visible_size.y)
        var final_pos := Vector2(rand_x, rand_y)

        chosen_created.position = final_pos

        var parent_node := get_parent()
        assert(parent_node != null)
        parent_node.add_child(chosen_created)
