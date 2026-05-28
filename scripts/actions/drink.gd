extends "res://scripts/actions/action.gd"

## Drinks carried drinkable items.

var item: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "drink"


# Parses the drinkable item from current scope.
func _prepare() -> void:
	character = parser.get_character(command)
	item = parser.match_item(command, parser.get_items_in_scope(character))


# Checks that the item is drinkable and carried.
func _check_preconditions() -> bool:
	if not was_matched(item, "I don't see it."):
		return false
	if not item.property_truthy("is_drink"):
		fail("That's not drinkable.")
		return false
	if not character.is_in_inventory(item):
		fail("You don't have it.")
		return false
	return true


# Removes the drink and clears thirst.
func _apply_effects() -> void:
	character.remove_from_inventory(item)
	item.remove_from_world()
	character.set_property("is_thirsty", false)
	if character == game.player:
		ok("You drink the %s." % item.name)
	else:
		ok("%s drinks the %s." % [character.name, item.name])
