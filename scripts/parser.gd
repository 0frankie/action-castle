extends RefCounted

## Library-style parser that resolves commands through registered actions.

const DEFAULT_ACTION_SCRIPTS: Array = [
	preload("res://scripts/actions/describe.gd"),
	preload("res://scripts/actions/go.gd"),
	preload("res://scripts/actions/get_item.gd"),
	preload("res://scripts/actions/drop_item.gd"),
	preload("res://scripts/actions/inventory.gd"),
	preload("res://scripts/actions/examine.gd"),
	preload("res://scripts/actions/light.gd"),
	preload("res://scripts/actions/give.gd"),
	preload("res://scripts/actions/attack.gd"),
	preload("res://scripts/actions/eat.gd"),
	preload("res://scripts/actions/drink.gd"),
]

const DIRECTION_ALIASES: Dictionary = {
	"n": "north",
	"s": "south",
	"e": "east",
	"w": "west",
	"u": "up",
	"d": "down",
}

var game: Variant = null
var actions: Array[GDScript] = []
var command_history: Array[Dictionary] = []


# Connects the parser to a game instance.
func setup(game_ref: Variant) -> void:
	game = game_ref
	actions.clear()
	for action_script in DEFAULT_ACTION_SCRIPTS:
		add_action(action_script)


# Registers an action class the parser can choose from.
func add_action(action_script: GDScript) -> void:
	actions.append(action_script)


# Parses a single command and returns action messages.
func parse_command(command: String) -> Array[String]:
	var cleaned_command := command.strip_edges().to_lower()
	command_history.append({"role": "user", "content": cleaned_command})
	if cleaned_command.is_empty():
		return ["Type a command or choose an action."]

	var action_script: Variant = _action_script_for(cleaned_command)
	if action_script == null:
		return ["I'm not sure what you want to do."]
	return _run_action(action_script, cleaned_command)


# Finds the character named in a command, defaulting to the player.
func get_character(command: String) -> Variant:
	var lowered_command := command.to_lower()
	for character_id in game.characters.keys():
		if character_id == game.PLAYER_ID:
			continue
		var character: Variant = game.characters[character_id]
		if lowered_command.contains(character_id) or lowered_command.contains(
			String(character.display_name).to_lower()
		):
			return character
	return game.player


# Finds a visible character mentioned in a command.
func match_character(command: String, candidate_characters: Dictionary) -> Variant:
	for character_id in candidate_characters.keys():
		var character: Variant = candidate_characters[character_id]
		var display_name := String(character.display_name).to_lower()
		if command.contains(character_id) or command.contains(display_name):
			return character
	return null


# Finds an item mentioned in a command from candidate items.
func match_item(command: String, candidate_items: Dictionary) -> Variant:
	for item_id in candidate_items.keys():
		var item: Variant = candidate_items[item_id]
		if command.contains(item_id) or command.contains(String(item.name)):
			return item
	return null


# Returns location and inventory items visible to a character.
func get_items_in_scope(character: Variant) -> Dictionary:
	var scoped_items: Dictionary = {}
	if character == null:
		character = game.player
	if character.location != null:
		for item_id in character.location.items.keys():
			scoped_items[item_id] = character.location.items[item_id]
	for item_id in character.inventory.keys():
		scoped_items[item_id] = character.inventory[item_id]
	return scoped_items


# Returns a normalized direction if a command names an available exit.
func get_direction(command: String, location: Variant) -> String:
	var normalized := command.strip_edges().to_lower()
	if normalized.begins_with("go "):
		normalized = normalized.trim_prefix("go ").strip_edges()
	normalized = DIRECTION_ALIASES.get(normalized, normalized)
	if location != null and location.connections.has(normalized):
		return normalized
	return ""


# Records a successful action message.
func ok(description: String) -> void:
	command_history.append({"role": "assistant", "content": description})


# Chooses the first registered action that matches a command.
func _action_script_for(command: String) -> Variant:
	for action_script in actions:
		var action: Variant = action_script.new()
		if action.matches_command(command, self):
			return action_script
	return null


# Instantiates and executes an action class.
func _run_action(action_script: GDScript, command: String) -> Array[String]:
	var action: Variant = action_script.new()
	var messages: Array[String] = action.execute(game, command)
	for message in messages:
		ok(message)
	return messages
