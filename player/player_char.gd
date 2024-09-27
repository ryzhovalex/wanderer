extends Node2D
class_name PlayerChar

func _ready():
    $AnimatedSprite2D.speed_scale = 0.35
    $AnimatedSprite2D.play("idle")

func _process(delta):
    position.x += delta
    if position.x < DistanceSv.player_char_starting_x:
        position.x = DistanceSv.player_char_starting_x
