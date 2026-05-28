extends "res://scripts/blocks/block.gd"

## Blocks a passage until a door is unlocked.

var door: Variant = null


# Connects this blocker to a door item.
func setup(door_ref: Variant) -> void:
	setup_block("A locked door blocks your way", "The door ahead is locked.")
	door = door_ref


# Checks whether the door is still locked.
func is_blocked() -> bool:
	return door != null and door.property_truthy("is_locked")
