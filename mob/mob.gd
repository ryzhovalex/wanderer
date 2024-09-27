extends Area2D
class_name Mob
signal hit

@export var stat: MobStat = MobStat.new()
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready():
    sprite.flip_h = true

func _process(delta):
    $AnimatedSprite2D.play()
    # TODO: Make mobs move towards character
    position += Vector2(-1, 0) * stat.move_spd * delta
