extends Area2D
class_name Mob
signal hit

@export var stat: MobStat

func _process(delta):
    $AnimatedSprite2D.play()
    position += Vector2(1, 1) * stat.move_spd * delta
