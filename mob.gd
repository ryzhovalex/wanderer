extends Area2D
signal hit

@export var speed = 5
var screen_size

func _ready():
    screen_size = get_viewport_rect().size

func _process(delta):
    $AnimatedSprite2D.play()
    position += Vector2(1, 1) * speed * delta
    # position = position.clamp(Vector2.ZERO, screen_size)

func start(pos):
    position = pos
    show()
    $CollisionShape2D.disabled = false
