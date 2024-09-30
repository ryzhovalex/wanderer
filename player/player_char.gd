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
    _maybe_move(delta)
    # Atk doesn't interrupt move
    _maybe_atk(delta)
    _reduce_move_spd_by_hp()

func _reduce_move_spd_by_hp():
    core.percent(stat.hp, stat.max_hp)

func _maybe_atk(_delta: float):
    if state == State.MainAtk || state == State.CircleAtk:
        return
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) \
            && !core.is_cooldown(main_atk_last_time, stat.main_atk_cooldown):
        state = State.MainAtk
        main_atk_last_time = core.time()
        _sprite.play("main_atk")
        return
    if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) \
            && !core.is_cooldown(
                circle_atk_last_time, stat.circle_atk_cooldown
            ):
        state = State.CircleAtk
        circle_atk_last_time = core.time()
        _sprite.play("circle_atk")

func _maybe_move(delta: float):
    var dir = 0
    if Input.is_key_pressed(KEY_A):
        dir = -1
    elif Input.is_key_pressed(KEY_D):
        dir = 1
    if state == State.Std:
        if dir == 0:
            _sprite.play("idle")
        else:
            _sprite.play("move")
    position.x += delta * stat.move_spd * dir
    if position.x < DistanceSv.player_char_starting_x:
        position.x = DistanceSv.player_char_starting_x

func _maybe_die():
    if stat.hp <= 0:
        GameSv.end()
        state = State.Die

func recv_dmg(dmg: int):
    stat.hp -= dmg
