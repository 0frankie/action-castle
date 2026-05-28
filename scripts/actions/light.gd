extends "res://scripts/actions/action.gd"

## Lights a carried lightable item.

var item: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "light"


# Parses the target item from current scope.
func _prepare() -> void:
	character = parser.get_character(command)
	item = parser.match_item(command, parser.get_items_in_scope(character))


# Checks that the target can be lit.
func _check_preconditions() -> bool:
	if not was_matched(item, "I don't see it."):
		return false
	if not character.is_in_inventory(item):
		fail("You don't have it.")
		return false
	if not item.property_truthy("is_lightable"):
		fail("That's not something that can be lit.")
		return false
	if item.property_truthy("is_lit"):
		fail("It is already lit.")
		return false
	return true


# Marks the item as lit.
func _apply_effects() -> void:
	item.set_property("is_lit", true)
	if character == game.player:
		ok("You light the %s. It glows." % item.name)
	else:
		ok("%s lights the %s. It glows." % [character.name, item.name])
