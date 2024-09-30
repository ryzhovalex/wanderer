extends Node2D
class_name PlayerChar

@export var stat: PlayerCharStat = PlayerCharStat.new()
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

# Distance are not distracted when moved backwards, but added only once
var covered_distance: int = 0

func _ready():
    _sprite.speed_scale = 0.35
    _sprite.play("idle")
    # Get back to the ground dude
    position.y = GroundSv.base_y

func _draw():
    # Test ground-like line
    draw_line(Vector2(-5000, 0.0), Vector2(5000, 0.0), Color.BLACK)

func _process(delta):
    _maybe_move(delta)
    var is_dead = _maybe_die()
    if is_dead:
        return

func _maybe_move(delta: float) -> bool:
    var dir = 0
    if Input.is_key_pressed(KEY_A):
        dir = -1
    elif Input.is_key_pressed(KEY_D):
        dir = 1
    if dir == 0:
        _sprite.play("idle")
    else:
        _sprite.play("move")
    position.x += delta * 100 * dir
    if position.x < DistanceSv.player_char_starting_x:
        position.x = DistanceSv.player_char_starting_x
    return dir != 0

func _maybe_die() -> bool:
    if stat.hp <= 0:
        GameSv.end()
        return true
    return false

func recv_dmg(dmg: int):
    # TODO: Implement
    print("Player character is damaged for %d" % dmg)
