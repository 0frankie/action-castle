extends "res://scripts/actions/action.gd"

## Picks the lone rose from the garden rosebush.

var rosebush: Variant = null
var rose: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "pick rose"


# Parses rosebush and rose references.
func _prepare() -> void:
	character = game.player
	rosebush = character.location.get_item("rosebush") if character.location != null else null
	rose = game.items["rose"]


# Checks whether the rose can be picked.
func _check_preconditions() -> bool:
	if rosebush == null:
		fail("There's no rosebush here.")
		return false
	if not rosebush.property_truthy("has_rose"):
		fail("The rosebush is bare.")
		return false
	return true


# Moves the rose into inventory.
func _apply_effects() -> void:
	rosebush.set_property("has_rose", false)
	character.add_to_inventory(rose)
	ok("You picked the lone rose from the rosebush.")
