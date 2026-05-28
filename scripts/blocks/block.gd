extends RefCounted

## Base movement blocker used by locations.

var name: String = ""
var blocked_description: String = ""


# Initializes shared blocker text.
func setup_block(block_name: String, description: String) -> void:
	name = block_name
	blocked_description = description


# Reports whether this blocker currently prevents movement.
func is_blocked() -> bool:
	return false
