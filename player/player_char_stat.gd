extends Stat
class_name PlayerCharStat

@export var max_hp: int = 500
@export var hp: int = 500

@export var move_spd: int = 30
@export var move_spd_reduce_per_hp_percent: float = 0.2

@export var main_atk_dmg: int = 50
# Range within the closest enemy will be chosen to hit. Additional enemies will
# be chosen next in the range.
@export var main_atk_range: int = 100
@export var main_atk_cooldown: int = 0
@export var main_atk_crit_chance: int = 20
@export var main_atk_crit_mul: int = 2
@export var main_atk_aoe_dmg_reduction_percent: int = 80

@export var circle_atk_dmg: int = 50
# Range to right and left in which everything will be damaged.
# Also blocks projectiles in the same range.
@export var circle_atk_range: int = 100
@export var circle_atk_cooldown: int = 10000
@export var circle_atk_crit_chance: int = 20
@export var circle_atk_crit_mul: int = 2
@export var circle_atk_aoe_dmg_reduction_percent: int = 10

@export var rage_cooldown: int = 60000
@export var rage_duration: int = 5000
