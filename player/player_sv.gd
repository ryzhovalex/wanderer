extends Sv

var score: int = 0
@onready var player_char: PlayerChar = get_tree().root.get_node("Char")
@onready var player_char_starting_point: Marker2D = get_tree().root.get_node(
    "CharStartingPoint"
)
