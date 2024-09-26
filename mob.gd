extends Area2D
class_name Mob
signal hit

@export var stat: MobStat

func _ready():
    rotation_degrees = -180

func _process(delta):
    $AnimatedSprite2D.play()
    # Mobs always move to the left, until something in their attack range
    position += Vector2(-1, 0) * stat.move_spd * delta
