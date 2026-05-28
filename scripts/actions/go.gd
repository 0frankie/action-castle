extends "res://scripts/actions/action.gd"

## Moves a character through the location graph.

var location: Variant = null
var direction: String = ""


# Returns the canonical command name for this action.
func action_name() -> String:
	return "go"


# Returns alternate direction commands for this action.
func action_aliases() -> Array[String]:
	return ["north", "n", "south", "s", "east", "e", "west", "w", "out", "in", "up", "u", "down", "d"]


# Matches commands that resolve to an exit from the current location.
func matches_command(command_text: String, parser_ref: Variant) -> bool:
	return parser_ref.get_direction(command_text, parser_ref.game.player.location) != ""


# Parses the actor, current location, and direction.
func _prepare() -> void:
	character = parser.get_character(command)
	location = character.location
	direction = parser.get_direction(command, location)


# Checks location, exit, and blocker preconditions.
func _check_preconditions() -> bool:
	if not location.here(character):
		fail("%s is not at %s." % [_character_name(character), location.name])
		return false
	if direction == "" or not location.connections.has(direction):
		fail("%s does not have an exit '%s'." % [location.name, direction])
		return false
	if location.is_blocked(direction):
		fail(location.get_block_description(direction))
		return false
	return true


# Moves the character and describes the new room.
func _apply_effects() -> void:
	var to_location: Variant = location.connections[direction]
	location.remove_character(character)
	to_location.add_character(character)
	if character == game.player:
		game.current_location = to_location
		to_location.has_been_visited = true
		if to_location.property_truthy("game_over"):
			game.game_over = true
			game.game_over_description = to_location.description
			ok(to_location.description)
		else:
			ok(game.describe_current_state())
