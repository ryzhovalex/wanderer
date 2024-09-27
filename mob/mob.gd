extends Area2D
class_name Mob
signal hit

@export var stat: MobStat = MobStat.new()
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _player_char: PlayerChar = core.find("PlayerChar")
enum State {
    Idle,
    Move,
    StartedAtk,
    EndedAtk,
    Die
}
var _state := State.Idle
var last_atk_time_ms: int = 0
var is_moving_backward: bool = false

func _ready():
    _sprite.connect("animation_finished", _on_anim_finished)
    assert(
        stat.closest_range <= stat.atk_range,
        "Idle range must be less than attack range"
    )

func _process(delta):
    if _state == State.Die:
        return
    if stat.hp > stat.max_hp:
        stat.hp = stat.max_hp
    if stat.hp <= 0:
        _die()
        return

    if _state == State.Idle || _state == State.Move:
        var distance := position.distance_to(_player_char.position)
        is_moving_backward = distance < stat.closest_range

    # Flip sprite to face the character
    if is_moving_backward:
        _sprite.flip_h = _player_char.position.x > position.x
    else:
        _sprite.flip_h = _player_char.position.x <= position.x

    if _is_in_atk_range() && !is_moving_backward:
        # Wait&Stare if atk is recharging, but player within the range
        if _state != State.Idle && _state != State.StartedAtk && _is_atk_on_cooldown():
            print_debug("idle")
            _state = State.Idle
            _sprite.play("idle")
            return
        _atk()
        return
    _move(delta)

func _die():
    if _state == State.Die:
        return
    _state = State.Die
    _sprite.play("die")

func _is_atk_on_cooldown():
    return core.current_ms() - last_atk_time_ms < stat.atk_cooldown_ms

func _on_anim_finished():
    print_debug("finish anim while %d" % _state)
    match _state:
        State.StartedAtk:
            if _is_in_atk_range():
                _send_dmg()
            _state = State.EndedAtk
        State.Die:
            queue_free()
            return

func _send_dmg():
    _player_char.recv_dmg(stat.atk_dmg)

func _is_in_atk_range() -> bool:
    var distance := position.distance_to(_player_char.position)
    return stat.atk_range >= distance

func _atk():
    if _state == State.StartedAtk || _is_atk_on_cooldown():
        return
    print_debug("atk")
    # Register an attack once animation starts, not on animation finish
    last_atk_time_ms = core.current_ms()
    _state = State.StartedAtk
    _sprite.play("atk")

func _move_backward_player_char(delta: float):
    position = position.move_toward(
        _player_char.position, stat.move_spd * delta * -1
    )

func _move_toward_player_char(delta: float):
    position = position.move_toward(
        _player_char.position,
        stat.move_spd * delta
    )

func _move(delta: float):
    if _state != State.Move:
        _state = State.Move
        _sprite.play("move")
    if is_moving_backward:
        _move_backward_player_char(delta)
        return
    _move_toward_player_char(delta)
