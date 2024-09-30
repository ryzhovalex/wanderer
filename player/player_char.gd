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
var real_move_spd: int = stat.move_spd
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
    draw_line(Vector2(-5000, 0.0), Vector2(5000, 0.0), Color.BLACK)

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
        return
    if Input.is_action_just_pressed("circle_atk") \
            && !core.is_cooldown(
                circle_atk_last_time, stat.circle_atk_cooldown
            ):
        state = State.CircleAtk
        circle_atk_last_time = core.time()
        _sprite.play("circle_atk")

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
