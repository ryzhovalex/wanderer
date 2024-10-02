extends Stat
class_name MobStat

@export var move_spd: float = 20

@export var max_hp: int = 100
@export var hp: int = 100

@export var external_dmg_recover: int = 3000

@export var atk_dmg: int = 10
@export var atk_range: int = 100
# How close the mob can be to the target. If the distance between mob and
# target is less than this value, the mob will try to make such distance on
# first possibility. If the distance is greater than this value, but less than
# `atk_range`, the mob will idle.
@export var closest_range: int = 50
@export var atk_cooldown: int = 3000
