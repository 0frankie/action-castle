extends "res://scripts/actions/action.gd"

## Reads lit candle runes to banish the ghost.

var candle: Variant = null
var ghost: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "read runes"


# Parses candle and ghost references.
func _prepare() -> void:
	character = game.player
	candle = parser.match_item("candle", parser.get_items_in_scope(character))
	ghost = character.location.characters.get("ghost", null)


# Checks whether the runes can be read.
func _check_preconditions() -> bool:
	if candle == null or not character.is_in_inventory(candle):
		fail("I don't see a candle here.")
		return false
	if ghost == null:
		fail("There is no ghost here.")
		return false
	if not candle.property_truthy("is_lit"):
		fail("The candle is not lit.")
		return false
	return true


# Banishes the ghost and drops its inventory.
func _apply_effects() -> void:
	ghost.set_property("is_banished", true)
	character.location.remove_character(ghost)
	var dropped_items: Array = ghost.inventory.values()
	for item in dropped_items:
		ghost.remove_from_inventory(item)
		character.location.add_item(item)
	ok("You read the runes on the candle and banish the ghost.")
