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

func _ready():
    _sprite.speed_scale = 0.35
    _sprite.play("idle")
    # Get back to the ground dude
    position.y = GroundSv.base_y
    _sprite.connect("animation_finished", _on_anim_finished)

func _on_anim_finished():
    match state:
        State.MainAtk:
            state = State.Std
        State.CircleAtk:
            state = State.Std

func _draw():
    # Test ground-like line
    draw_line(Vector2(-100000, 0.0), Vector2(100000, 0.0), Color.BLACK)

func _process(delta):
    _maybe_die()
    if state == State.Die:
        return
    _set_move_spd_by_hp()
    _maybe_move(delta)
    # Atk doesn't interrupt move
    _maybe_atk(delta)

func _set_move_spd_by_hp():
    var hp_percent = core.percent(stat.hp, stat.max_hp)
    var missing_hp_percent = 100 - hp_percent
    var reduce = stat.move_spd_reduce_per_hp_percent
    real_move_spd = floor(stat.move_spd - (missing_hp_percent * reduce))

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

        var mobs = core.group_members("mobs")

        # Instead raycasting, check what's in close proximity by just
        # coordinates
        if dot >= 0:
            # Check X+
            var pos_range = position.x + stat.main_atk_range
            _dmg_mobs_in_range(pos_range, mobs, "right")
        else:
            # Check X-
            var pos_range = position.x - stat.main_atk_range
            _dmg_mobs_in_range(pos_range, mobs, "left")

        return
    if Input.is_action_just_pressed("circle_atk") \
            && !core.is_cooldown(
                circle_atk_last_time, stat.circle_atk_cooldown
            ):
        state = State.CircleAtk
        circle_atk_last_time = core.time()
        _sprite.play("circle_atk")

func _dmg_mobs_in_range(
    pos_range: int,
    all_mobs: Array[Node],
    check: StringName
):
    var in_range_mobs: Array[Mob] = []
    var closest_mob: Mob = null
    var dmg_closest: int = stat.main_atk_dmg
    var dmg_other: int = floor(
        stat.main_atk_dmg * stat.main_atk_aoe_dmg_reduction_percent
    )
    # Crit works simultaneously for both main target and AOE
    var is_crit = Rnd.chance(stat.main_atk_crit_chance)
    if is_crit:
        dmg_closest = floor(dmg_closest * stat.main_atk_crit_mul)
        dmg_other = floor(dmg_other * stat.main_atk_crit_mul)

    for mob in all_mobs:
        if (check == "right" && position.x < mob.position.x && mob.position.x < pos_range) \
            || (check == "left" && pos_range < mob.position.x && mob.position.x < position.x):
            in_range_mobs.push_back(mob)
            if closest_mob == null \
                    || mob.position.x < closest_mob.position.x:
                closest_mob = mob

    print(all_mobs, " ", closest_mob,  in_range_mobs)
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
    if position.x < DistanceSv.player_char_starting_x:
        position.x = DistanceSv.player_char_starting_x

func _maybe_die():
    if stat.hp <= 0:
        GameSv.end()
        state = State.Die
        _sprite.play("die")

func recv_dmg(dmg: int):
    stat.hp -= dmg
