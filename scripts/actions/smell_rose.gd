extends "res://scripts/actions/action.gd"

## Smells the rose and makes the actor happy.

var rose: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "smell rose"


# Parses the rose from inventory.
func _prepare() -> void:
	character = parser.get_character(command)
	rose = character.inventory.get("rose", null)


# Checks whether the actor is carrying the rose.
func _check_preconditions() -> bool:
	if rose != null:
		return true
	fail("There is no rose to smell.")
	return false


# Applies the rose's emotional effect.
func _apply_effects() -> void:
	for message in game.smell_rose(character):
		ok(message)
