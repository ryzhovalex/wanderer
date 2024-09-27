extends Node2D
class_name PlayerChar

func _ready():
    $AnimatedSprite2D.speed_scale = 0.35
    $AnimatedSprite2D.play("idle")
    # Get back to the ground dude
    position.y = GroundSv.base_y

func _draw():
    # Test ground-like line
    draw_line(Vector2(-5000, 0.0), Vector2(5000, 0.0), Color.BLACK)

func _process(delta):
    position.x += delta * 8
    if position.x < DistanceSv.player_char_starting_x:
        position.x = DistanceSv.player_char_starting_x

func recv_dmg(dmg: int):
    # TODO: Implement
    print("Player character is damaged for %d" % dmg)
