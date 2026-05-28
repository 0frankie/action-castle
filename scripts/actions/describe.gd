extends "res://scripts/actions/action.gd"

## Describes the current game state.


# Returns the canonical command name for this action.
func action_name() -> String:
	return "look"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["l"]


# Descriptions always have the current player as actor.
func _check_preconditions() -> bool:
	return game.player != null


# Emits the current room description.
func _apply_effects() -> void:
	ok(game.describe_current_state())
