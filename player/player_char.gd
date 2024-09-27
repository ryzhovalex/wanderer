extends Node2D
class_name PlayerChar

func _ready():
    $AnimatedSprite2D.speed_scale = 0.35
    $AnimatedSprite2D.play("idle")
    # Get back to the ground dude
    position.y = GroundSv.base_y

func _draw():
    draw_line(Vector2(position.x, GroundSv.base_y), Vector2(5000, GroundSv.base_y), Color.GREEN, 1.0)

func _process(delta):
    position.x += delta
    if position.x < DistanceSv.player_char_starting_x:
        position.x = DistanceSv.player_char_starting_x
