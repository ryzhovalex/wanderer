extends Area2D
class_name Mob
signal hit

@export var stat: MobStat = MobStat.new()
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var _player_char: PlayerChar = core.current("PlayerChar")
enum State {
    Move,
    Atk,
    Die
}
var _state := State.Move


func _ready():
    _sprite.flip_h = true
    _sprite.connect("animation_finished", _on_anim_finished)

func _process(delta):
    if _state == State.Move:
        return
    if stat.hp > stat.max_hp:
        stat.hp = stat.max_hp
    if stat.hp <= 0:
        _die()
        return
    if _is_in_atk_range():
        _atk()
        return
    _move_toward(delta)

func _die():
    if _state == State.Die:
        return
    _state = State.Die
    _sprite.play("die")

func _on_anim_finished():
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
    _state = State.Atk
    _sprite.play("atk")
    _sprite.connect("animation_finished", func(): queue_free())

func _move_toward(delta: float):
    position = position.move_toward(_player_char.position, stat.move_spd * delta)
