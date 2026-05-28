extends "res://scripts/actions/action.gd"

## Examines a visible or carried item.

var item: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "examine"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["look at", "x"]


# Parses the item from room and inventory scope.
func _prepare() -> void:
	character = parser.get_character(command)
	item = parser.match_item(command, parser.get_items_in_scope(character))


# Always allows examine so unmatched items get a generic response.
func _check_preconditions() -> bool:
	return character != null


# Emits the target item's examine text.
func _apply_effects() -> void:
	if item == null:
		ok("You don't see anything special.")
	else:
		ok(item.examine_text)
