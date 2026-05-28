extends "res://scripts/actions/action.gd"

## Gives a carried item to another character.

var recipient: Variant = null
var item: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "give"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["hand"]


# Parses recipient and carried item.
func _prepare() -> void:
	character = game.player
	item = parser.match_item(command, character.inventory)
	recipient = parser.match_character(command, character.location.characters)
	if recipient == character:
		recipient = null


# Checks that the item and recipient are available.
func _check_preconditions() -> bool:
	if not was_matched(item, "You don't have that."):
		return false
	if recipient == null:
		fail("Who do you want to give it to?")
		return false
	return true


# Transfers the item and triggers automatic consume/smell effects.
func _apply_effects() -> void:
	character.remove_from_inventory(item)
	recipient.add_to_inventory(item)
	ok("You gave the %s to %s." % [item.name, recipient.display_name])
	if recipient.property_truthy("is_hungry") and item.property_truthy("is_food"):
		ok(game.consume_item(recipient, item))
		if recipient.id == "troll" and item.id == "fish":
			recipient.set_property("reaction_text", "gulp!")
			recipient.set_property("reacted_to_fish", true)
			ok("The troll pats his belly and stops blocking the bridge.")
	elif recipient.id == "guard" and item.id == "fish":
		recipient.set_property("reaction_text", "gross!")
		recipient.set_property("reacted_to_fish", true)
		recipient.set_property("is_suspicious", false)
		ok("The knight recoils from the reeking fish and loosens his watch on the gate.")
	if item.property_truthy("scent") and item.id == "rose":
		for message in game.smell_rose(recipient):
			ok(message)
