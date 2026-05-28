extends "res://scripts/actions/action.gd"

## Lists the acting character's inventory.


# Returns the canonical command name for this action.
func action_name() -> String:
	return "inventory"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["i"]


# Checks that an actor was parsed.
func _check_preconditions() -> bool:
	return character != null


# Emits a readable inventory description.
func _apply_effects() -> void:
	if character.inventory.is_empty():
		ok("Your inventory is empty.")
		return
	var lines: Array[String] = ["Your inventory contains:"]
	for item_id in character.inventory.keys():
		lines.append("* %s" % character.inventory[item_id].description)
	ok("\n".join(lines))
