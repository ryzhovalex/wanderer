extends Node

# Fetches node relative to scene
func find(t: String = ".") -> Node:
    return get_tree().get_current_scene().get_node(t)

func time() -> int:
    return Time.get_ticks_msec()

func utc() -> int:
    return floor(Time.get_unix_time_from_system() * 1000)

func is_cooldown(
    last: int, cooldown: int, unlock_starters: bool = true
) -> bool:
    # By default make cooldowns unlocked at the start of the engine
    if unlock_starters && last == 0:
        return false
    return time() - last <= cooldown

func percent(current_val: int, max_val: int) -> int:
    var f: float = float(current_val) / max_val
    f *= 100
    if f > 100:
        f = 100
    return floor(f)
