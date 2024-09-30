extends Sv

var services: Array[Sv] = [
    SpawnerSv
]

func _ready():
    init()

func init():
    var process_frame = get_tree().process_frame
    if process_frame.is_connected(init):
        process_frame.disconnect(init)
    var physics_frame = get_tree().physics_frame
    if physics_frame.is_connected(init):
        physics_frame.disconnect(init)

    for service in services:
        service.init()

func destroy():
    for service in services:
        service.destroy()

func start():
    pass

func end():
    pass

func restart():
    get_tree().reload_current_scene()
    get_tree().process_frame.connect(init)
    get_tree().physics_frame.connect(init)

func _process(_delta):
    if Input.is_action_just_pressed("restart"):
        restart()
