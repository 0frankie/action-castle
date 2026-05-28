extends "res://scripts/actions/action.gd"

## Crowns a royal character carrying the crown.

var crown: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "wear crown"


# Parses the acting character and crown.
func _prepare() -> void:
	character = parser.get_character(command)
	crown = character.inventory.get("crown", null)


# Checks crown possession and royalty.
func _check_preconditions() -> bool:
	if crown == null:
		fail("You don't have a crown.")
		return false
	if not character.property_truthy("is_royal"):
		if character == game.player:
			fail("You are not royalty.")
		else:
			fail("%s is not royalty." % String(character.name).capitalize())
		return false
	return true


# Marks the character as crowned.
func _apply_effects() -> void:
	character.set_property("is_crowned", true)
	if character == game.player:
		ok("You place the crown upon your head.")
	else:
		ok("%s places the crown upon their head." % String(character.name).capitalize())
