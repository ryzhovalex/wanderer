extends Sv

var score: int = 0
@onready var player_char: PlayerChar = get_node("/root/PlayerChar")

func _ready():
    print(player_char)
