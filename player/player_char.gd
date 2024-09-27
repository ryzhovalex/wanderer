extends Node2D
class_name PlayerChar

func _ready():
    $AnimatedSprite2D.speed_scale = 0.35
    $AnimatedSprite2D.play("idle")
