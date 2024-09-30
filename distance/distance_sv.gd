extends Sv

# How many pixels in 1 meter
@export var meter_to_pixels: float = 1

var player_char: PlayerChar
var covered_distance_text: Label

var player_char_starting_x: int

func init():
    player_char = core.find("PlayerChar")
    player_char_starting_x = floor(player_char.position.x)
    covered_distance_text = core.find("CoveredDistanceText")

func destroy():
    pass

func _physics_process(_delta):
    player_char.covered_distance = _process_covered_distance()
    covered_distance_text.text = \
        "%d meters" % _get_covered_distance_as_meters()

func _process_covered_distance() -> int:
    var new_covered_distance: int = \
        floor(player_char.position.x) - player_char_starting_x
    if new_covered_distance < player_char.covered_distance:
        new_covered_distance = player_char.covered_distance
    return new_covered_distance

func _get_covered_distance_as_meters() -> int:
    return floor(player_char.covered_distance / meter_to_pixels)
