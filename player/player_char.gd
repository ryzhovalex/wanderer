extends Node2D
class_name PlayerChar

@export var stat: PlayerCharStat = PlayerCharStat.new()
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

# Distance are not distracted when moved backwards, but added only once
var covered_distance: int = 0
enum State {
    Std,
    MainAtk,
    CircleAtk,
    Die
}
var real_move_spd: float = stat.move_spd
var state: State = State.Std
var main_atk_last_time: int = 0
var circle_atk_last_time: int = 0
var rage_last_time: int = 0

var last_dmg_per_sec_time: int = 0

@onready var hp_text: Label = $Camera2D.get_node("HpText")
@onready var move_spd_text: Label = $Camera2D.get_node("MoveSpdText")
@onready var covered_distance_text = $Camera2D.get_node("CoveredDistanceText")
@onready var cam = $Camera2D

# How many pixels in 1 meter
@export var meter_to_pixels: float = 1

var starting_x: float

func _physics_process(_delta):
    covered_distance = _process_covered_distance()

func _process_covered_distance() -> int:
    var new_covered_distance: int = \
        floor(position.x) - starting_x
    if new_covered_distance < covered_distance:
        new_covered_distance = covered_distance
    return new_covered_distance

func _get_covered_distance_as_meters() -> int:
    return floor(covered_distance / meter_to_pixels)

func _ready():
    _sprite.speed_scale = 0.35
    _sprite.play("idle")
    # Get back to the ground dude
    position.y = GroundSv.base_y
    _sprite.connect("animation_finished", _on_anim_finished)
    starting_x = position.x
    cam.add_to_group("cam")

func _on_anim_finished():
    match state:
        State.MainAtk:
            state = State.Std
        State.CircleAtk:
            state = State.Std

func _draw():
    # Test ground-like line
    draw_line(Vector2(-100000, 0.0), Vector2(100000, 0.0), Color.BLACK)

func _dmg_per_sec():
    # We don't want this damage to be applied before the first second
    if !core.is_cooldown(last_dmg_per_sec_time, 1000, false):
        last_dmg_per_sec_time = core.time()
        stat.hp -= stat.hp_dmg_per_sec

func _display():
    hp_text.text = "%d/%d HP" % [stat.hp, stat.max_hp]
    move_spd_text.text = "%d/%d Speed" % [real_move_spd, stat.move_spd]
    covered_distance_text.text = \
        "%d meters" % _get_covered_distance_as_meters()

func _process(delta):
    _dmg_per_sec()
    _maybe_die()
    _set_move_spd_by_hp()
    _display()
    if state == State.Die:
        return
    _maybe_move(delta)
    # Atk doesn't interrupt move
    _maybe_atk(delta)

func _set_move_spd_by_hp():
    var hp_percent = core.percent(stat.hp, stat.max_hp)
    var missing_hp_percent = 1 - hp_percent
    var reduce = stat.move_spd_reduce_per_missing_hp_percent
    var move_spd_reduce_percent = missing_hp_percent * 100 * reduce
    real_move_spd = floor(
        stat.move_spd - (stat.move_spd * move_spd_reduce_percent)
    )

func _maybe_atk(_delta: float):
    if state == State.MainAtk || state == State.CircleAtk:
        return
    if Input.is_action_just_pressed("main_atk") \
            && !core.is_cooldown(main_atk_last_time, stat.main_atk_cooldown):
        state = State.MainAtk
        main_atk_last_time = core.time()
        _sprite.play("main_atk")

        # Attack direction is determined by cursor position relative to
        # character
        var mouse_dir: Vector2 = (core.get_mouse_pos() - position).normalized()
        var forward_dir = Vector2(1, 0)
        var dot = forward_dir.dot(mouse_dir)
        _sprite.flip_h = dot < 0

        var mobs = core.group_members("mob")
        var dmg_closest: int = stat.main_atk_dmg
        var dmg_other: int = floor(
            stat.main_atk_dmg * stat.main_atk_aoe_dmg_reduction_percent
        )
        # Crit works simultaneously for both main target and AOE
        var is_crit = Rnd.chance(stat.main_atk_crit_chance)
        if is_crit:
            dmg_closest = floor(dmg_closest * stat.main_atk_crit_mul)
            dmg_other = floor(dmg_other * stat.main_atk_crit_mul)

        # Instead raycasting, check what's in close proximity by just
        # coordinates
        if dot >= 0:
            # Check X+
            var pos_range = position.x + stat.main_atk_range
            _dmg_mobs_in_range(pos_range, dmg_closest, dmg_other, mobs, "right")
        else:
            # Check X-
            var pos_range = position.x - stat.main_atk_range
            _dmg_mobs_in_range(pos_range, dmg_closest, dmg_other, mobs, "left")

        return
    if Input.is_action_just_pressed("circle_atk") \
            && !core.is_cooldown(
                circle_atk_last_time, stat.circle_atk_cooldown
            ):
        state = State.CircleAtk
        circle_atk_last_time = core.time()
        _sprite.play("circle_atk")

        var mobs = core.group_members("mob")
        var right_pos_range = position.x + stat.circle_atk_range
        var left_pos_range = position.x - stat.circle_atk_range
        var dmg = stat.circle_atk_dmg
        var is_crit = Rnd.chance(stat.circle_atk_crit_chance)
        if is_crit:
            dmg = floor(dmg * stat.circle_atk_crit_mul)
        # Same dmg for closest and other mobs
        _dmg_mobs_in_range(right_pos_range, dmg, dmg, mobs, "right")
        _dmg_mobs_in_range(left_pos_range, dmg, dmg, mobs, "left")

func _dmg_mobs_in_range(
    pos_range: int,
    dmg_closest: int,
    dmg_other: int,
    all_mobs: Array[Node],
    check: StringName
):
    var in_range_mobs: Array[Mob] = []
    var closest_mob: Mob = null

    for mob in all_mobs:
        if (check == "right" && position.x < mob.position.x && mob.position.x < pos_range) \
            || (check == "left" && pos_range < mob.position.x && mob.position.x < position.x):
            in_range_mobs.push_back(mob)
            if closest_mob == null \
                    || mob.position.x < closest_mob.position.x:
                closest_mob = mob

    if closest_mob == null:
        return
    closest_mob.recv_dmg(dmg_closest)
    for mob in in_range_mobs:
        mob.recv_dmg(dmg_other)

func _maybe_move(delta: float):
    # Cannot move during circle attack
    if state == State.CircleAtk:
        return
    var dir = 0
    if Input.is_action_pressed("move_left"):
        dir = -1
    elif Input.is_action_pressed("move_right"):
        dir = 1
    if state == State.Std:
        _sprite.flip_h = dir < 0
        if dir == 0:
            _sprite.play("idle")
        else:
            _sprite.play("move")
    position.x += delta * real_move_spd * dir
    if position.x < starting_x:
        position.x = starting_x

func _maybe_die():
    if stat.hp <= 0:
        GameSv.end()
        state = State.Die
        _sprite.play("die")

func recv_dmg(dmg: int):
    stat.hp -= dmg
