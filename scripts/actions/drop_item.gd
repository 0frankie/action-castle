extends "res://scripts/actions/action.gd"

## Drops an inventory item into the current location.

var location: Variant = null
var item: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "drop"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["toss"]


# Parses the inventory item to drop.
func _prepare() -> void:
	character = parser.get_character(command)
	location = character.location
	item = parser.match_item(command, character.inventory)


# Checks that the actor is carrying the item.
func _check_preconditions() -> bool:
	if not was_matched(item, "You don't have that."):
		return false
	return character.is_in_inventory(item)


# Moves the item into the current location.
func _apply_effects() -> void:
	character.remove_from_inventory(item)
	location.add_item(item)
	ok("%s dropped the %s in the %s." % [_character_sentence_name(character), item.name, location.name])
