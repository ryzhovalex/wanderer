extends Sv

@onready var player_char: PlayerChar = core.current("PlayerChar")
var player_char_starting_x: int
# Distance are not distracted when moved backwards, but added only once
var covered_distance: int

func _ready():
    player_char_starting_x = floor(player_char.position.x)
    print("Player character is starting from x %d" % player_char_starting_x)

func _get_covered_distance() -> int:
    var new_covered_distance: int = \
        floor(player_char.position.x) - player_char_starting_x
    if new_covered_distance < covered_distance:
        new_covered_distance = covered_distance
    return new_covered_distance
