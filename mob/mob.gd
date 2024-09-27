extends Area2D
class_name Mob
signal hit

@export var stat: MobStat = MobStat.new()

func _ready():
    rotation_degrees = -180

func _process(delta):
    $AnimatedSprite2D.play()
    # TODO: Make mobs move towards character
    position += Vector2(-1, 0) * stat.move_spd * delta
