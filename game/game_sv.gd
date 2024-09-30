extends Sv

func start():
    pass

func end():
    pass

func restart():
    get_tree().reload_current_scene()

func _process(_delta):
    if Input.is_key_pressed(KEY_R):
        restart()
