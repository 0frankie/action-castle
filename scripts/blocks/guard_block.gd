extends "res://scripts/blocks/block.gd"

## Blocks the feasting hall while the guard is suspicious.

var location: Variant = null
var guard: Variant = null


# Connects this blocker to the courtyard guard.
func setup(location_ref: Variant, guard_ref: Variant) -> void:
	setup_block("A guard blocks your way", "The guard refuses to let you pass.")
	location = location_ref
	guard = guard_ref


# Checks whether the guard still blocks the east exit.
func is_blocked() -> bool:
	if guard == null:
		return false
	if not location.here(guard):
		return false
	if guard.property_truthy("is_dead"):
		return false
	if guard.property_truthy("is_unconscious"):
		return false
	return guard.property_truthy("is_suspicious")
