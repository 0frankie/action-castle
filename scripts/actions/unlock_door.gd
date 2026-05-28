extends "res://scripts/actions/action.gd"

## Unlocks the tower door with the brass key.

var location: Variant = null
var door: Variant = null
var key: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "unlock door"


# Parses door and key references from current scope.
func _prepare() -> void:
	character = game.player
	location = character.location
	door = parser.match_item("door", parser.get_items_in_scope(character))
	key = parser.match_item("key", parser.get_items_in_scope(character))


# Checks whether the door can be unlocked.
func _check_preconditions() -> bool:
	if not was_matched(door, "I don't see a door here."):
		return false
	if door.location != location:
		fail("I don't see a door here.")
		return false
	if not door.property_truthy("is_locked"):
		fail("The door is already unlocked.")
		return false
	if key == null or not character.is_in_inventory(key):
		fail("You don't have a key.")
		return false
	return true


# Unlocks the door item.
func _apply_effects() -> void:
	door.set_property("is_locked", false)
	door.examine_text = "THE DOOR IS UNLOCKED."
	ok("You unlock the door with the brass key.")
