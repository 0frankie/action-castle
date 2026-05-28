extends RefCounted

## Base command object for text-adventure actions.

var game: Variant = null
var parser: Variant = null
var command: String = ""
var character: Variant = null
var messages: Array[String] = []


# Returns the canonical command name for this action.
func action_name() -> String:
	return ""


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return []


# Returns true when this action should handle a command.
func matches_command(command_text: String, parser_ref: Variant) -> bool:
	var names := [action_name()]
	names.append_array(action_aliases())
	for candidate in names:
		var candidate_text := String(candidate).to_lower()
		if candidate_text.is_empty():
			continue
		if command_text == candidate_text or command_text.begins_with("%s " % candidate_text):
			return true
	return false


# Runs this action against the current game state.
func execute(game_ref: Variant, command_text: String) -> Array[String]:
	game = game_ref
	parser = game.parser
	command = command_text.to_lower().strip_edges()
	messages = []
	_prepare()
	if _check_preconditions():
		_apply_effects()
	return messages


# Prepares parsed references before checking preconditions.
func _prepare() -> void:
	character = parser.get_character(command)


# Checks whether this action can be applied.
func _check_preconditions() -> bool:
	return true


# Applies this action's effects.
func _apply_effects() -> void:
	return


# Adds a successful message to this action result.
func ok(description: String) -> void:
	messages.append(description)


# Adds a failure message to this action result.
func fail(description: String) -> void:
	messages.append(description)


# Fails if a parsed object was not matched.
func was_matched(value: Variant, error_message: String = "I don't see it.") -> bool:
	if value != null:
		return true
	fail(error_message)
	return false


# Checks whether a thing is at a location.
func at(thing: Variant, location: Variant) -> bool:
	return thing != null and location != null and thing.location == location


# Checks whether a character is carrying an item.
func is_in_inventory(holder: Variant, item: Variant) -> bool:
	if holder != null and holder.is_in_inventory(item):
		return true
	fail("%s does not have the %s." % [_character_name(holder), item.name])
	return false


# Checks a truthy property and emits a custom failure.
func has_property(thing: Variant, property_name: String, error_message: String) -> bool:
	if thing != null and thing.property_truthy(property_name):
		return true
	fail(error_message)
	return false


# Returns the player-friendly name for a character.
func _character_name(actor: Variant) -> String:
	if actor == null:
		return "Someone"
	if actor.id == game.PLAYER_ID:
		return "You"
	return actor.display_name


# Returns a capitalized prose name for a character.
func _character_sentence_name(actor: Variant) -> String:
	if actor == null:
		return "Someone"
	if actor.id == game.PLAYER_ID:
		return "You"
	return String(actor.name).capitalize()
