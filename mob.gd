extends Area2D
signal hit

@export var spd = 5
@export var max_hp = 100
@export var hp = max_hp
@export var dmg = 10
@export var atk_spd = 2

var screen_size

func _ready():
    screen_size = get_viewport_rect().size

func _process(delta):
    $AnimatedSprite2D.play()
    position += Vector2(1, 1) * spd * delta
