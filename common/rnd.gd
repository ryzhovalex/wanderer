extends Node

var gen = RandomNumberGenerator.new()

# Randomly hit chance.
func chance(chance_val: float) -> bool:
    var rnd_val = gen.randf_range(0, 1)
    return rnd_val <= chance_val
