extends Sv

var score: int = 0
@onready var player_char: PlayerChar = core.current("PlayerChar")

func _ready():
    print(player_char)
