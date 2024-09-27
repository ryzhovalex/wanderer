extends Node2D
class_name PlayerChar

@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
    _sprite.speed_scale = 0.35
    _sprite.play("idle")
    # Get back to the ground dude
    position.y = GroundSv.base_y

func _draw():
    # Test ground-like line
    draw_line(Vector2(-5000, 0.0), Vector2(5000, 0.0), Color.BLACK)

func _process(delta):
    var dir = 0
    if Input.is_key_pressed(KEY_LEFT):
        dir = -1
    elif Input.is_key_pressed(KEY_RIGHT):
        dir = 1
    if dir == 0:
        _sprite.play("idle")
    else:
        _sprite.play("move")
    position.x += delta * 100 * dir
    if position.x < DistanceSv.player_char_starting_x:
        position.x = DistanceSv.player_char_starting_x

func recv_dmg(dmg: int):
    # TODO: Implement
    print("Player character is damaged for %d" % dmg)
