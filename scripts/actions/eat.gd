extends "res://scripts/actions/action.gd"

## Consumes edible items.

var item: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "eat"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["eats", "ate", "eating"]


# Parses the edible item from current scope.
func _prepare() -> void:
	character = parser.get_character(command)
	item = parser.match_item(command, parser.get_items_in_scope(character))


# Checks that the item is edible and carried.
func _check_preconditions() -> bool:
	if not was_matched(item, "I don't see it."):
		return false
	if not item.property_truthy("is_food"):
		fail("That's not edible.")
		return false
	if not character.is_in_inventory(item):
		fail("You don't have it.")
		return false
	return true


# Removes the item and clears hunger.
func _apply_effects() -> void:
	ok(game.consume_item(character, item))
