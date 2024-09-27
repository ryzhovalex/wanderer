extends Sv

# How many pixels in 1 meter
@export var meter_to_pixels: float = 1

@onready var player_char: PlayerChar = core.find("PlayerChar")
@onready var covered_distance_text: Label = core.find("CoveredDistanceText")

var player_char_starting_x: int
# Distance are not distracted when moved backwards, but added only once
var covered_distance: int

func _ready():
    player_char_starting_x = floor(player_char.position.x)
    print("Player character is starting from x %d" % player_char_starting_x)

func _physics_process(_delta):
    covered_distance = _process_covered_distance()
    covered_distance_text.text = \
        "%d meters" % _get_covered_distance_as_meters()

func _process_covered_distance() -> int:
    var new_covered_distance: int = \
        floor(player_char.position.x) - player_char_starting_x
    if new_covered_distance < covered_distance:
        new_covered_distance = covered_distance
    return new_covered_distance

func _get_covered_distance_as_meters() -> int:
    return floor(covered_distance / meter_to_pixels)
