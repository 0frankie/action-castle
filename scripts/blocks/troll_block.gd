extends "res://scripts/blocks/block.gd"

## Blocks the drawbridge while the troll is present and hungry.

var location: Variant = null
var troll: Variant = null


# Connects this blocker to the drawbridge troll.
func setup(location_ref: Variant, troll_ref: Variant) -> void:
	setup_block("A troll blocks your way", "A hungry troll blocks your way.")
	location = location_ref
	troll = troll_ref


# Checks whether the troll still blocks the drawbridge.
func is_blocked() -> bool:
	if troll == null:
		return false
	if not location.here(troll):
		return false
	if troll.property_truthy("is_dead"):
		return false
	if troll.property_truthy("is_unconscious"):
		return false
	return troll.property_truthy("is_hungry")
