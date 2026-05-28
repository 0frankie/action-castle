class_name ActionCastleGame
extends RefCounted

## Builds and runs Action Castle using modular text-adventure objects.

const PLAYER_ID: String = "player"
const START_LOCATION_ID: String = "cottage"

const LOCATION_SCRIPT: GDScript = preload("res://scripts/things/location.gd")
const ITEM_SCRIPT: GDScript = preload("res://scripts/things/item.gd")
const CHARACTER_SCRIPT: GDScript = preload("res://scripts/things/character.gd")
const PARSER_SCRIPT: GDScript = preload("res://scripts/parser.gd")

const TROLL_BLOCK_SCRIPT: GDScript = preload("res://scripts/blocks/troll_block.gd")
const GUARD_BLOCK_SCRIPT: GDScript = preload("res://scripts/blocks/guard_block.gd")
const DARKNESS_BLOCK_SCRIPT: GDScript = preload("res://scripts/blocks/darkness_block.gd")
const DOOR_BLOCK_SCRIPT: GDScript = preload("res://scripts/blocks/door_block.gd")

const CATCH_FISH_SCRIPT: GDScript = preload("res://scripts/actions/catch_fish.gd")
const PICK_ROSE_SCRIPT: GDScript = preload("res://scripts/actions/pick_rose.gd")
const SMELL_ROSE_SCRIPT: GDScript = preload("res://scripts/actions/smell_rose.gd")
const UNLOCK_DOOR_SCRIPT: GDScript = preload("res://scripts/actions/unlock_door.gd")
const READ_RUNES_SCRIPT: GDScript = preload("res://scripts/actions/read_runes.gd")
const PROPOSE_SCRIPT: GDScript = preload("res://scripts/actions/propose.gd")
const WEAR_CROWN_SCRIPT: GDScript = preload("res://scripts/actions/wear_crown.gd")
const SIT_ON_THRONE_SCRIPT: GDScript = preload("res://scripts/actions/sit_on_throne.gd")

const LOCATION_DATA: Dictionary = {
	"cottage": {
		"name": "Cottage",
		"description": "You are standing in a small cottage.",
		"connections": {"out": "garden_path"},
	},
	"garden_path": {
		"name": "Garden Path",
		"description": "You are standing on a lush garden path. There is a cottage here.",
		"connections": {"south": "fishing_pond", "north": "winding_path"},
	},
	"fishing_pond": {
		"name": "Fishing Pond",
		"description": "You are at the edge of a small fishing pond.",
		"connections": {},
	},
	"winding_path": {
		"name": "Winding Path",
		"description": "You are walking along a winding path. There is a tall tree here.",
		"connections": {"up": "top_of_tree", "east": "drawbridge"},
	},
	"top_of_tree": {
		"name": "Top of the Tall Tree",
		"description": "You are at the top of the tall tree.",
		"connections": {"jump": "death"},
	},
	"drawbridge": {
		"name": "Drawbridge",
		"description": "You are standing on one side of a drawbridge leading to ACTION CASTLE.",
		"connections": {"east": "courtyard"},
	},
	"courtyard": {
		"name": "Courtyard",
		"description": "You are in the courtyard of ACTION CASTLE.",
		"connections": {"up": "tower_stairs", "down": "dungeon_stairs", "east": "feasting_hall"},
	},
	"tower_stairs": {
		"name": "Tower Stairs",
		"description": "You are climbing the stairs to the tower. There is a locked door here.",
		"connections": {"up": "tower"},
	},
	"tower": {
		"name": "Tower",
		"description": "You are inside a tower.",
		"connections": {},
	},
	"dungeon_stairs": {
		"name": "Dungeon Stairs",
		"description": "You are climbing the stairs down to the dungeon.",
		"connections": {"down": "dungeon"},
		"flags": {"is_dark": true},
	},
	"dungeon": {
		"name": "Dungeon",
		"description": "You are in the dungeon. There is a spooky ghost here.",
		"connections": {},
	},
	"feasting_hall": {
		"name": "Great Feasting Hall",
		"description": "You stand inside the Great Feasting Hall.",
		"connections": {"east": "throne_room"},
	},
	"throne_room": {
		"name": "Throne Room",
		"description": "This is the throne room of ACTION CASTLE.",
		"connections": {},
	},
	"death": {
		"name": "The Afterlife",
		"description": "You are dead. GAME OVER.",
		"connections": {},
		"flags": {"game_over": true},
	},
}

const ITEM_DATA: Dictionary = {
	"lamp": {
		"name": "lamp",
		"description": "a lamp",
		"examine": "A LAMP.",
		"owner": PLAYER_ID,
		"flags": {"is_lightable": true, "is_lit": false},
		"hints": ["light lamp"],
	},
	"pole": {
		"name": "pole",
		"description": "a fishing pole",
		"examine": "A SIMPLE FISHING POLE.",
		"location": "cottage",
	},
	"branch": {
		"name": "branch",
		"description": "a stout, dead branch",
		"examine": "IT LOOKS LIKE IT WOULD MAKE A GOOD CLUB.",
		"location": "top_of_tree",
		"flags": {"is_weapon": true, "is_fragile": true},
	},
	"candle": {
		"name": "candle",
		"description": "a strange candle",
		"examine": "THE CANDLE IS COVERED IN STRANGE RUNES.",
		"location": "feasting_hall",
		"flags": {"is_lightable": true, "is_lit": false},
		"hints": ["light candle", "read runes"],
	},
	"pond": {
		"name": "pond",
		"description": "a small fishing pond",
		"examine": "THERE ARE FISH IN THE POND.",
		"location": "fishing_pond",
		"gettable": false,
		"flags": {"has_fish": true},
		"hints": ["catch fish", "catch fish with pole"],
	},
	"rosebush": {
		"name": "rosebush",
		"description": "a rosebush",
		"examine": "THE ROSEBUSH CONTAINS A SINGLE RED ROSE. IT IS BEAUTIFUL.",
		"location": "garden_path",
		"gettable": false,
		"flags": {"has_rose": true},
		"hints": ["pick rose"],
	},
	"throne": {
		"name": "throne",
		"description": "an ornate golden throne",
		"examine": "AN ORNATE GOLDEN THRONE.",
		"location": "throne_room",
		"gettable": false,
		"hints": ["sit on throne"],
	},
	"door": {
		"name": "door",
		"description": "a door",
		"examine": "THE DOOR IS SECURELY LOCKED.",
		"location": "tower_stairs",
		"gettable": false,
		"flags": {"is_locked": true},
		"hints": ["unlock door"],
	},
	"key": {
		"name": "key",
		"description": "a brass key",
		"examine": "THIS LOOKS USEFUL.",
		"owner": "guard",
	},
	"sword": {
		"name": "sword",
		"description": "a short sword",
		"examine": "A SHARP SHORT SWORD.",
		"owner": "guard",
		"flags": {"is_weapon": true},
	},
	"crown": {
		"name": "crown",
		"description": "a crown",
		"examine": "A CROWN FIT FOR A KING.",
		"owner": "ghost",
		"hints": ["wear crown"],
	},
	"fish": {
		"name": "fish",
		"description": "a dead fish",
		"examine": "IT SMELLS TERRIBLE.",
		"exists": false,
		"flags": {
			"is_food": true,
			"taste": "disgusting! It's raw! And definitely not sashimi-grade!",
		},
		"hints": ["eat fish"],
	},
	"rose": {
		"name": "rose",
		"description": "a red rose",
		"examine": "IT SMELLS GOOD.",
		"exists": false,
		"hints": ["smell rose"],
	},
}

const CHARACTER_DATA: Dictionary = {
	PLAYER_ID: {
		"name": "The player",
		"display_name": "You",
		"description": "You are a simple peasant destined for greatness.",
		"location": START_LOCATION_ID,
		"flags": {"emotional_state": "restless", "is_married": false, "is_royal": false},
	},
	"troll": {
		"name": "troll",
		"display_name": "Troll",
		"description": "A mean troll",
		"location": "drawbridge",
		"flags": {"is_hungry": true, "character_type": "troll"},
	},
	"guard": {
		"name": "guard",
		"display_name": "Guard",
		"description": "A castle guard",
		"location": "courtyard",
		"flags": {
			"is_conscious": true,
			"is_suspicious": true,
			"character_type": "human",
		},
	},
	"princess": {
		"name": "princess",
		"display_name": "Princess",
		"description": "A princess who is beautiful and lonely.",
		"location": "tower",
		"flags": {
			"is_royal": true,
			"emotional_state": "sad and lonely",
			"is_married": false,
			"character_type": "human",
		},
	},
	"ghost": {
		"name": "ghost",
		"display_name": "Ghost",
		"description": "A ghost with bony, claw-like fingers and who is wearing a crown.",
		"location": "dungeon",
		"flags": {"character_type": "ghost", "is_dead": true, "is_banished": false},
	},
}

const ROSE_SMELLS: Array[String] = [
	"sweetly intoxicating",
	"delicately fragrant",
	"richly floral",
	"freshly aromatic",
	"deeply romantic",
	"majestically royal",
	"sunny and cheerful",
]

var locations: Dictionary = {}
var items: Dictionary = {}
var characters: Dictionary = {}
var player: Variant = null
var current_location: Variant = null
var parser: Variant = null
var game_over: bool = false
var won: bool = false
var game_over_description: String = ""
var last_messages: Array[String] = []


# Seeds random choices and creates the starting world state.
func _init() -> void:
	randomize()
	reset()


# Restores the world to the notebook's initial Action Castle state.
func reset() -> void:
	locations.clear()
	items.clear()
	characters.clear()
	game_over = false
	won = false
	game_over_description = ""
	last_messages.clear()

	_create_locations()
	_connect_locations()
	_create_characters()
	_create_items()
	_create_blocks()
	_create_parser()

	player = characters[PLAYER_ID]
	current_location = player.location
	current_location.has_been_visited = true


# Runs one or more typed commands and returns messages for the UI log.
func run_command(command: String) -> Array[String]:
	var cleaned_command := command.strip_edges()
	var messages: Array[String] = []
	if cleaned_command.is_empty():
		return ["Type a command or choose an action."]
	if game_over and cleaned_command.to_lower() != "restart":
		return ["The story is over. Press Restart to play again."]
	if cleaned_command.to_lower() == "restart":
		reset()
		return ["The story begins again.", describe_current_state()]

	var command_parts := cleaned_command.split(",", false)
	for command_part in command_parts:
		var single_command := String(command_part).strip_edges()
		messages.append_array(parser.parse_command(single_command))
		if game_over:
			break

	last_messages = messages
	return messages


# Describes the current room, exits, visible items, and visible characters.
func describe_current_state() -> String:
	var lines: Array[String] = [current_location.description]
	var exits := get_available_exits()
	if not exits.is_empty():
		lines.append("")
		lines.append("Exits:")
		for exit_data in exits:
			lines.append("* %s to %s" % [String(exit_data["direction"]).capitalize(), exit_data["to_name"]])

	var visible_items := get_visible_items_for_location(current_location.id)
	if not visible_items.is_empty():
		lines.append("")
		lines.append("You see:")
		for item_id in visible_items:
			var item: Variant = items[item_id]
			lines.append("* %s" % item.description)
			for hint in item.get_command_hints():
				lines.append("  %s" % hint)

	var present_characters := get_visible_characters_for_location(current_location.id)
	if not present_characters.is_empty():
		lines.append("")
		lines.append("Characters:")
		for character_id in present_characters:
			lines.append("* %s" % characters[character_id].description)

	return "\n".join(lines)


# Returns location data for the UI.
func get_current_location() -> Dictionary:
	return {
		"id": current_location.id,
		"name": current_location.name,
		"description": current_location.description,
	}


# Returns exits from the current location in insertion order.
func get_available_exits() -> Array[Dictionary]:
	var exits: Array[Dictionary] = []
	for direction in current_location.connections.keys():
		var to_location: Variant = current_location.connections[direction]
		exits.append({
			"direction": direction,
			"to": to_location.id,
			"to_name": to_location.name,
			"blocked": current_location.is_blocked(direction),
			"block_description": current_location.get_block_description(direction),
		})
	return exits


# Returns item ids currently visible in a location.
func get_visible_items_for_location(location_id: String) -> Array[String]:
	var visible_items: Array[String] = []
	var location: Variant = locations.get(location_id, null)
	if location == null:
		return visible_items
	for item_id in location.items.keys():
		var item: Variant = location.items[item_id]
		if item.exists:
			visible_items.append(item_id)
	return visible_items


# Returns non-player character ids currently visible in a location.
func get_visible_characters_for_location(location_id: String) -> Array[String]:
	var visible_characters: Array[String] = []
	var location: Variant = locations.get(location_id, null)
	if location == null:
		return visible_characters
	for character_id in location.characters.keys():
		if character_id != PLAYER_ID:
			visible_characters.append(character_id)
	return visible_characters


# Returns the player's inventory item ids.
func get_inventory() -> Array[String]:
	var inventory: Array[String] = []
	for item_id in player.inventory.keys():
		inventory.append(item_id)
	return inventory


# Returns a friendly label for an item id.
func get_item_label(item_id: String) -> String:
	if not items.has(item_id):
		return item_id.capitalize()
	return String(items[item_id].name).capitalize()


# Returns a friendly label for a character id.
func get_character_label(character_id: String) -> String:
	if not characters.has(character_id):
		return character_id.capitalize()
	return characters[character_id].display_name


# Returns commands that are useful in the current state.
func get_suggested_commands() -> Array[String]:
	var commands: Array[String] = ["look", "inventory"]
	for exit_data in get_available_exits():
		commands.append("go %s" % exit_data["direction"])

	for item_id in get_visible_items_for_location(current_location.id):
		var item: Variant = items[item_id]
		if item.gettable:
			commands.append("get %s" % item.name)
		for hint in item.get_command_hints():
			commands.append(hint)

	for item_id in get_inventory():
		for hint in items[item_id].get_command_hints():
			commands.append(hint)

	if current_location.id == "fishing_pond" and player.inventory.has("pole"):
		commands.append("catch fish with pole")
	if current_location.id == "drawbridge" and player.inventory.has("fish"):
		commands.append("give fish to troll")
	if current_location.id == "courtyard" and player.inventory.has("branch"):
		commands.append("attack guard with branch")
	if current_location.id == "tower_stairs" and player.inventory.has("key"):
		commands.append("unlock door")
	if current_location.id == "dungeon" and player.inventory.has("candle"):
		commands.append("read runes")
	if current_location.id == "tower" and player.inventory.has("rose"):
		commands.append("give rose to princess")
		commands.append("propose to princess")
	if current_location.id == "throne_room" and player.inventory.has("crown"):
		commands.append("sit on throne")

	return _dedupe(commands)


# Returns all renderable state needed by the scene controller.
func get_state_snapshot() -> Dictionary:
	var item_locations: Dictionary = {}
	for item_id in items.keys():
		var item: Variant = items[item_id]
		if not item.exists:
			item_locations[item_id] = ""
		elif item.owner != null:
			item_locations[item_id] = "inventory:%s" % item.owner.id
		elif item.location != null:
			item_locations[item_id] = item.location.id
		else:
			item_locations[item_id] = ""

	var character_locations: Dictionary = {}
	for character_id in characters.keys():
		var character: Variant = characters[character_id]
		character_locations[character_id] = character.location.id if character.location != null else ""

	return {
		"current_location_id": current_location.id,
		"item_locations": item_locations,
		"character_locations": character_locations,
		"game_over": game_over,
		"won": won,
	}


# Consumes a food item and returns the resulting prose.
func consume_item(character: Variant, item: Variant) -> String:
	character.remove_from_inventory(item)
	item.remove_from_world()
	character.set_property("is_hungry", false)

	var message := "You eat the %s." % item.name
	if character != player:
		message = "%s eats the %s." % [String(character.name).capitalize(), item.name]
	if item.property_truthy("taste"):
		var taste := String(item.get_property("taste"))
		message += " It tastes %s" % taste
		if not taste.ends_with(".") and not taste.ends_with("!") and not taste.ends_with("?"):
			message += "."
	return message


# Applies the rose-smelling effect and returns prose messages.
func smell_rose(character: Variant) -> Array[String]:
	if not character.inventory.has("rose"):
		return ["There is no rose to smell."]

	var rose: Variant = character.inventory["rose"]
	var scent: String = ROSE_SMELLS[randi() % ROSE_SMELLS.size()]
	rose.set_property("scent", scent)
	character.set_property("emotional_state", "happy")
	if character == player:
		return ["You smell the rose. It smells %s." % scent, "You are happy."]
	return [
		"%s smells the rose. It smells %s." % [String(character.name).capitalize(), scent],
		"%s is happy." % String(character.name).capitalize(),
	]


# Instantiates locations from static world data.
func _create_locations() -> void:
	for location_id in LOCATION_DATA.keys():
		var location: Variant = LOCATION_SCRIPT.new()
		location.setup_location(location_id, LOCATION_DATA[location_id])
		locations[location_id] = location


# Connects locations using the same auto-reverse behavior as Python.
func _connect_locations() -> void:
	for location_id in LOCATION_DATA.keys():
		var location: Variant = locations[location_id]
		for direction in LOCATION_DATA[location_id].get("connections", {}).keys():
			var connected_id: String = LOCATION_DATA[location_id]["connections"][direction]
			location.add_connection(direction, locations[connected_id])


# Instantiates characters and places them in starting locations.
func _create_characters() -> void:
	for character_id in CHARACTER_DATA.keys():
		var character: Variant = CHARACTER_SCRIPT.new()
		var data: Dictionary = CHARACTER_DATA[character_id]
		character.setup_character(character_id, data)
		characters[character_id] = character
		locations[data["location"]].add_character(character)


# Instantiates items and places them in rooms or inventories.
func _create_items() -> void:
	for item_id in ITEM_DATA.keys():
		var item: Variant = ITEM_SCRIPT.new()
		var data: Dictionary = ITEM_DATA[item_id]
		item.setup_item(item_id, data)
		items[item_id] = item
		if not item.exists:
			continue
		if data.has("owner"):
			characters[data["owner"]].add_to_inventory(item)
		elif data.has("location"):
			locations[data["location"]].add_item(item)


# Creates the custom Action Castle route blockers.
func _create_blocks() -> void:
	var troll_block: Variant = TROLL_BLOCK_SCRIPT.new()
	troll_block.setup(locations["drawbridge"], characters["troll"])
	locations["drawbridge"].add_block("east", troll_block)

	var guard_block: Variant = GUARD_BLOCK_SCRIPT.new()
	guard_block.setup(locations["courtyard"], characters["guard"])
	locations["courtyard"].add_block("east", guard_block)

	var darkness_block: Variant = DARKNESS_BLOCK_SCRIPT.new()
	darkness_block.setup(locations["dungeon_stairs"])
	locations["dungeon_stairs"].add_block("down", darkness_block)

	var door_block: Variant = DOOR_BLOCK_SCRIPT.new()
	door_block.setup(items["door"])
	locations["tower_stairs"].add_block("up", door_block)


# Creates the parser and registers custom action classes.
func _create_parser() -> void:
	parser = PARSER_SCRIPT.new()
	parser.setup(self)
	parser.add_action(CATCH_FISH_SCRIPT)
	parser.add_action(PICK_ROSE_SCRIPT)
	parser.add_action(SMELL_ROSE_SCRIPT)
	parser.add_action(UNLOCK_DOOR_SCRIPT)
	parser.add_action(READ_RUNES_SCRIPT)
	parser.add_action(PROPOSE_SCRIPT)
	parser.add_action(WEAR_CROWN_SCRIPT)
	parser.add_action(SIT_ON_THRONE_SCRIPT)


# Removes duplicate command labels while preserving order.
func _dedupe(values: Array[String]) -> Array[String]:
	var seen: Dictionary = {}
	var result: Array[String] = []
	for value in values:
		if seen.has(value):
			continue
		seen[value] = true
		result.append(value)
	return result
