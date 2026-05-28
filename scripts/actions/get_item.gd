extends "res://scripts/actions/action.gd"

## Moves a gettable item from a room into inventory.

var location: Variant = null
var item: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "get"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["take"]


# Parses the target item from the current location.
func _prepare() -> void:
	character = parser.get_character(command)
	location = character.location
	item = parser.match_item(command, location.items)


# Checks that the item is visible and gettable.
func _check_preconditions() -> bool:
	if not was_matched(item, "I don't see it."):
		return false
	if not location.here(item):
		fail("There is no %s here." % item.name)
		return false
	if not item.gettable:
		fail("%s is not gettable." % String(item.name).capitalize())
		return false
	return true


# Transfers the item into the acting character's inventory.
func _apply_effects() -> void:
	character.add_to_inventory(item)
	if character == game.player:
		ok("You got the %s." % item.name)
	else:
		ok("%s got the %s." % [character.name, item.name])
