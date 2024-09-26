extends Node

# How often to call spawn instruction
@export var period_ms: float = 1000
@export var spawned_scene: PackedScene
@export var spawned_rnd_stats: Array[MobStat]

var last_spawned_ms: float = 0

func _process(_delta):
    var current_ms := Time.get_ticks_msec()
    if current_ms - last_spawned_ms > period_ms:
        last_spawned_ms = current_ms
        var chosen_stat: MobStat = spawned_rnd_stats.pick_random()
        if chosen_stat == null:
            printerr("No content in `spawned_rnd_stats` array")
            return
        var chosen: Mob = spawned_scene.instantiate()
        chosen.stat = chosen_stat

        var visible_size := get_viewport().get_visible_rect().size
        var rnd_gen := RandomNumberGenerator.new()
        var rnd_x := rnd_gen.randf_range(0, visible_size.x)
        var rnd_y := rnd_gen.randf_range(0, visible_size.y)
        var final_pos := Vector2(rnd_x, rnd_y)

        chosen.position = final_pos

        var parent_node := get_parent()
        assert(parent_node != null)
        parent_node.add_child(chosen)
