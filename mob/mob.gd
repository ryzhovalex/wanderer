extends Area2D
class_name Mob
signal hit

@export var stat: MobStat = MobStat.new()
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _player_char: PlayerChar = core.current("PlayerChar")
enum State {
    Idle,
    Move,
    Atk,
    Die
}
var _state := State.Idle
var last_atk_time_ms: int = 0

func _ready():
    _sprite.connect("animation_finished", _on_anim_finished)

func _process(delta):
    if _state == State.Die:
        return
    if stat.hp > stat.max_hp:
        stat.hp = stat.max_hp
    if stat.hp <= 0:
        _die()
        return
    if _is_in_atk_range():
        # Wait&Stare if atk is recharging, but player within the range
        if _state != State.Atk && _is_atk_on_cooldown():
            print_debug("idle")
            _state = State.Idle
            _sprite.play("idle")
            return
        _atk()
        return
    _move_toward(delta)

func _die():
    if _state == State.Die:
        return
    _state = State.Die
    _sprite.play("die")

func _is_atk_on_cooldown():
    return Time.get_ticks_msec() - last_atk_time_ms < stat.atk_cooldown_ms

func _on_anim_finished():
    print_debug("finish anim while %d" % _state)
    match _state:
        State.Atk:
            if _is_in_atk_range():
                _send_dmg()
        State.Die:
            queue_free()
            return

func _send_dmg():
    _player_char.recv_dmg(stat.atk_dmg)

func _is_in_atk_range() -> bool:
    var distance := position.distance_to(_player_char.position)
    return stat.atk_range >= distance

func _atk():
    if _state == State.Atk:
        return
    print_debug("atk")
    _state = State.Atk
    _sprite.play("atk")

func _move_toward(delta: float):
    _sprite.play("move")
    # Flip sprite to face the character
    _sprite.flip_h = _player_char.position.x < position.x
    position = position.move_toward(_player_char.position, stat.move_spd * delta)
