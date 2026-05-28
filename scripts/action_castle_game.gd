class_name ActionCastleGame
extends RefCounted

## Rule/state model for the 2D Action Castle adaptation.

const PLAYER_ID: String = "player"
const START_LOCATION_ID: String = "cottage"
const NO_OWNER: String = ""
const NO_LOCATION: String = ""

const DIRECTION_ALIASES: Dictionary = {
	"n": "north",
	"s": "south",
	"e": "east",
	"w": "west",
	"u": "up",
	"d": "down",
}

const LOCATION_DATA: Dictionary = {
	"cottage": {
		"name": "Cottage",
		"description": "You are standing in a small cottage.",
		"connections": {"out": "garden_path"},
	},
	"garden_path": {
		"name": "Garden Path",
		"description": "You are standing on a lush garden path. There is a cottage here.",
		"connections": {"in": "cottage", "south": "fishing_pond", "north": "winding_path"},
	},
	"fishing_pond": {
		"name": "Fishing Pond",
		"description": "You are at the edge of a small fishing pond.",
		"connections": {"north": "garden_path"},
	},
	"winding_path": {
		"name": "Winding Path",
		"description": "You are walking along a winding path. There is a tall tree here.",
		"connections": {"south": "garden_path", "up": "top_of_tree", "east": "drawbridge"},
	},
	"top_of_tree": {
		"name": "Top of the Tall Tree",
		"description": "You are at the top of the tall tree.",
		"connections": {"down": "winding_path", "jump": "death"},
	},
	"drawbridge": {
		"name": "Drawbridge",
		"description": "You are standing on one side of a drawbridge leading to ACTION CASTLE.",
		"connections": {"west": "winding_path", "east": "courtyard"},
	},
	"courtyard": {
		"name": "Courtyard",
		"description": "You are in the courtyard of ACTION CASTLE.",
		"connections": {
			"west": "drawbridge",
			"up": "tower_stairs",
			"down": "dungeon_stairs",
			"east": "feasting_hall",
		},
	},
	"tower_stairs": {
		"name": "Tower Stairs",
		"description": "You are climbing the stairs to the tower. There is a locked door here.",
		"connections": {"down": "courtyard", "up": "tower"},
	},
	"tower": {
		"name": "Tower",
		"description": "You are inside a tower.",
		"connections": {"down": "tower_stairs"},
	},
	"dungeon_stairs": {
		"name": "Dungeon Stairs",
		"description": "You are climbing the stairs down to the dungeon.",
		"connections": {"up": "courtyard", "down": "dungeon"},
		"flags": {"is_dark": true},
	},
	"dungeon": {
		"name": "Dungeon",
		"description": "You are in the dungeon. There is a spooky ghost here.",
		"connections": {"up": "dungeon_stairs"},
	},
	"feasting_hall": {
		"name": "Great Feasting Hall",
		"description": "You stand inside the Great Feasting Hall.",
		"connections": {"west": "courtyard", "east": "throne_room"},
	},
	"throne_room": {
		"name": "Throne Room",
		"description": "This is the throne room of ACTION CASTLE.",
		"connections": {"west": "feasting_hall"},
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
var current_location_id: String = START_LOCATION_ID
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
	locations = {}
	items = {}
	characters = {}
	current_location_id = START_LOCATION_ID
	game_over = false
	won = false
	game_over_description = ""
	last_messages = []

	for location_id in LOCATION_DATA.keys():
		var data: Dictionary = LOCATION_DATA[location_id]
		locations[location_id] = {
			"name": data["name"],
			"description": data["description"],
			"connections": data.get("connections", {}).duplicate(true),
			"flags": data.get("flags", {}).duplicate(true),
		}

	for item_id in ITEM_DATA.keys():
		var data: Dictionary = ITEM_DATA[item_id]
		items[item_id] = {
			"name": data["name"],
			"description": data["description"],
			"examine": data.get("examine", data["description"]),
			"gettable": data.get("gettable", true),
			"exists": data.get("exists", true),
			"location": data.get("location", NO_LOCATION),
			"owner": data.get("owner", NO_OWNER),
			"flags": data.get("flags", {}).duplicate(true),
			"hints": data.get("hints", []).duplicate(true),
		}

	for character_id in CHARACTER_DATA.keys():
		var data: Dictionary = CHARACTER_DATA[character_id]
		characters[character_id] = {
			"name": data["name"],
			"display_name": data.get("display_name", data["name"]),
			"description": data["description"],
			"location": data["location"],
			"flags": data.get("flags", {}).duplicate(true),
		}


# Runs one or more typed commands and returns messages for the UI log.
func run_command(command: String) -> Array[String]:
	var cleaned_command := command.strip_edges()
	var messages: Array[String] = []
	if cleaned_command.is_empty():
		messages.append("Type a command or choose an action.")
		return messages
	if game_over and cleaned_command.to_lower() != "restart":
		messages.append("The story is over. Press Restart to play again.")
		return messages
	if cleaned_command.to_lower() == "restart":
		reset()
		messages.append("The story begins again.")
		messages.append(describe_current_state())
		last_messages = messages
		return messages

	var command_parts := cleaned_command.split(",", false)
	for command_part in command_parts:
		var single_command := String(command_part).strip_edges()
		messages.append_array(_run_single_command(single_command))
		if game_over:
			break

	last_messages = messages
	return messages


# Describes the current room, exits, visible items, and visible characters.
func describe_current_state() -> String:
	var location: Dictionary = locations[current_location_id]
	var lines: Array[String] = [location["description"]]
	var exits := get_available_exits()
	if not exits.is_empty():
		lines.append("")
		lines.append("Exits:")
		for exit_data in exits:
			lines.append(
				"* %s to %s" % [
					String(exit_data["direction"]).capitalize(),
					locations[exit_data["to"]]["name"],
				]
			)

	var visible_items := get_visible_items_for_location(current_location_id)
	if not visible_items.is_empty():
		lines.append("")
		lines.append("You see:")
		for item_id in visible_items:
			lines.append("* %s" % items[item_id]["description"])
			for hint in items[item_id]["hints"]:
				lines.append("  %s" % hint)

	var present_characters := get_visible_characters_for_location(current_location_id)
	if not present_characters.is_empty():
		lines.append("")
		lines.append("Characters:")
		for character_id in present_characters:
			lines.append("* %s" % characters[character_id]["description"])

	return "\n".join(lines)


# Returns location data for the UI.
func get_current_location() -> Dictionary:
	return locations[current_location_id]


# Returns exits from the current location in notebook order.
func get_available_exits() -> Array[Dictionary]:
	var exits: Array[Dictionary] = []
	var connections: Dictionary = locations[current_location_id]["connections"]
	for direction in connections.keys():
		exits.append({
			"direction": direction,
			"to": connections[direction],
			"blocked": _is_blocked(current_location_id, direction),
			"block_description": _block_description(current_location_id, direction),
		})
	return exits


# Returns item ids currently visible in a location.
func get_visible_items_for_location(location_id: String) -> Array[String]:
	var visible_items: Array[String] = []
	for item_id in items.keys():
		if _item_exists_at_location(item_id, location_id):
			visible_items.append(item_id)
	return visible_items


# Returns non-player character ids currently visible in a location.
func get_visible_characters_for_location(location_id: String) -> Array[String]:
	var visible_characters: Array[String] = []
	for character_id in characters.keys():
		if character_id == PLAYER_ID:
			continue
		if characters[character_id]["location"] == location_id:
			visible_characters.append(character_id)
	return visible_characters


# Returns the player's inventory item ids.
func get_inventory() -> Array[String]:
	return _inventory_of(PLAYER_ID)


# Returns a friendly label for an item id.
func get_item_label(item_id: String) -> String:
	if not items.has(item_id):
		return item_id.capitalize()
	return String(items[item_id]["name"]).capitalize()


# Returns a friendly label for a character id.
func get_character_label(character_id: String) -> String:
	if not characters.has(character_id):
		return character_id.capitalize()
	return characters[character_id]["display_name"]


# Returns commands that are useful in the current state.
func get_suggested_commands() -> Array[String]:
	var commands: Array[String] = ["look", "inventory"]
	for exit_data in get_available_exits():
		commands.append("go %s" % exit_data["direction"])

	for item_id in get_visible_items_for_location(current_location_id):
		if items[item_id]["gettable"]:
			commands.append("get %s" % items[item_id]["name"])
		for hint in items[item_id]["hints"]:
			commands.append(hint)

	for item_id in get_inventory():
		for hint in items[item_id]["hints"]:
			commands.append(hint)

	if current_location_id == "fishing_pond" and _has_inventory_item("pole"):
		commands.append("catch fish with pole")
	if current_location_id == "drawbridge" and _has_inventory_item("fish"):
		commands.append("give fish to troll")
	if current_location_id == "courtyard" and _has_inventory_item("branch"):
		commands.append("attack guard with branch")
	if current_location_id == "tower_stairs" and _has_inventory_item("key"):
		commands.append("unlock door")
	if current_location_id == "dungeon" and _has_inventory_item("candle"):
		commands.append("read runes")
	if current_location_id == "tower" and _has_inventory_item("rose"):
		commands.append("give rose to princess")
		commands.append("propose to princess")
	if current_location_id == "throne_room" and _has_inventory_item("crown"):
		commands.append("sit on throne")

	return _dedupe(commands)


# Returns all renderable state needed by the scene controller.
func get_state_snapshot() -> Dictionary:
	var item_locations: Dictionary = {}
	for item_id in items.keys():
		var item: Dictionary = items[item_id]
		if not item["exists"]:
			item_locations[item_id] = NO_LOCATION
		elif item["owner"] != NO_OWNER:
			item_locations[item_id] = "inventory:%s" % item["owner"]
		else:
			item_locations[item_id] = item["location"]

	var character_locations: Dictionary = {}
	for character_id in characters.keys():
		character_locations[character_id] = characters[character_id]["location"]

	return {
		"current_location_id": current_location_id,
		"item_locations": item_locations,
		"character_locations": character_locations,
		"game_over": game_over,
		"won": won,
	}


# Routes one parsed command to the relevant rule implementation.
func _run_single_command(command: String) -> Array[String]:
	var lower_command := command.to_lower()
	if lower_command == "look" or lower_command == "l":
		return [describe_current_state()]
	if lower_command == "inventory" or lower_command == "i":
		return [_describe_inventory()]

	var direction := _direction_from_command(lower_command)
	if direction != "":
		return _go(direction)
	if lower_command.contains("catch fish"):
		return _catch_fish(lower_command)
	if lower_command.contains("pick rose"):
		return _pick_rose()
	if lower_command.contains("smell rose"):
		return _smell_rose(PLAYER_ID)
	if lower_command.contains("unlock door"):
		return _unlock_door()
	if lower_command.contains("read runes"):
		return _read_runes()
	if lower_command.contains("propose"):
		return _propose(lower_command)
	if lower_command.contains("wear crown"):
		return _wear_crown(_character_from_command(lower_command))
	if lower_command.contains("sit on throne"):
		return _sit_on_throne(_character_from_command(lower_command))
	if lower_command.begins_with("take ") or lower_command.begins_with("get "):
		return _get_item(lower_command)
	if lower_command.begins_with("drop "):
		return _drop_item(lower_command)
	if lower_command.begins_with("examine ") or lower_command.begins_with("x "):
		return _examine_item(lower_command)
	if lower_command.begins_with("look at "):
		return _examine_item(lower_command)
	if lower_command.contains("light"):
		return _light_item(lower_command)
	if lower_command.contains("give"):
		return _give_item(lower_command)
	if lower_command.contains("attack") or lower_command.contains("hit "):
		return _attack(lower_command)
	if lower_command.contains("eat "):
		return _eat_command(lower_command)
	if lower_command.contains("drink "):
		return ["That's not drinkable."]

	return ["I'm not sure what you want to do."]


# Moves the player if the requested direction exists and is not blocked.
func _go(direction: String) -> Array[String]:
	var connections: Dictionary = locations[current_location_id]["connections"]
	if not connections.has(direction):
		return ["%s does not have an exit '%s'." % [
			locations[current_location_id]["name"],
			direction,
		]]
	if _is_blocked(current_location_id, direction):
		return [_block_description(current_location_id, direction)]

	current_location_id = connections[direction]
	characters[PLAYER_ID]["location"] = current_location_id
	if _location_flag(current_location_id, "game_over"):
		game_over = true
		game_over_description = locations[current_location_id]["description"]
		return [game_over_description]

	return [describe_current_state()]


# Takes an item from the current location into the player's inventory.
func _get_item(command: String) -> Array[String]:
	var item_id := _match_item(command, get_visible_items_for_location(current_location_id))
	if item_id == "":
		return ["I don't see it."]
	if not items[item_id]["gettable"]:
		return ["%s is not gettable." % String(items[item_id]["name"]).capitalize()]

	_set_item_owner(item_id, PLAYER_ID)
	return ["You got the %s." % items[item_id]["name"]]


# Drops an inventory item into the current location.
func _drop_item(command: String) -> Array[String]:
	var item_id := _match_item(command, _inventory_of(PLAYER_ID))
	if item_id == "":
		return ["You don't have that."]

	_set_item_location(item_id, current_location_id)
	return ["You dropped the %s in the %s." % [
		items[item_id]["name"],
		locations[current_location_id]["name"],
	]]


# Examines a visible or carried item.
func _examine_item(command: String) -> Array[String]:
	var item_id := _match_item(command, _items_in_scope(PLAYER_ID))
	if item_id == "":
		return ["You don't see anything special."]
	return [items[item_id]["examine"]]


# Lights a lightable inventory item.
func _light_item(command: String) -> Array[String]:
	var item_id := _match_item(command, _items_in_scope(PLAYER_ID))
	if item_id == "":
		return ["I don't see it."]
	if not _has_inventory_item(item_id):
		return ["You don't have it."]
	if not _item_flag(item_id, "is_lightable"):
		return ["That's not something that can be lit."]
	if _item_flag(item_id, "is_lit"):
		return ["It is already lit."]

	items[item_id]["flags"]["is_lit"] = true
	return ["You light the %s. It glows." % items[item_id]["name"]]


# Catches a fish when the player has the pole and is at the pond.
func _catch_fish(command: String) -> Array[String]:
	if current_location_id != "fishing_pond" or not _item_exists_at_location("pond", "fishing_pond"):
		return ["There's no pond here."]
	if not _item_flag("pond", "has_fish"):
		return ["The pond has no fish."]
	if not command.contains("with pole") or not _has_inventory_item("pole"):
		return ["You reach into the pond, but the fish are too fast."]

	items["pond"]["flags"]["has_fish"] = false
	items["fish"]["exists"] = true
	_set_item_owner("fish", PLAYER_ID)
	return ["You dip the hook into the pond and catch a fish."]


# Picks the lone rose from the garden rosebush.
func _pick_rose() -> Array[String]:
	if not _item_exists_at_location("rosebush", current_location_id):
		return ["There's no rosebush here."]
	if not _item_flag("rosebush", "has_rose"):
		return ["The rosebush is bare."]

	items["rosebush"]["flags"]["has_rose"] = false
	items["rose"]["exists"] = true
	_set_item_owner("rose", PLAYER_ID)
	return ["You picked the lone rose from the rosebush."]


# Makes a character happy by smelling the rose.
func _smell_rose(character_id: String) -> Array[String]:
	if not _character_has_item(character_id, "rose"):
		return ["There is no rose to smell."]

	var scent: String = ROSE_SMELLS[randi() % ROSE_SMELLS.size()]
	items["rose"]["flags"]["scent"] = scent
	characters[character_id]["flags"]["emotional_state"] = "happy"
	if character_id == PLAYER_ID:
		return [
			"You smell the rose. It smells %s." % scent,
			"You are happy.",
		]
	return [
		"%s smells the rose. It smells %s." % [
			_capitalize_character_name(character_id),
			scent,
		],
		"%s is happy." % _capitalize_character_name(character_id),
	]


# Gives an inventory item to a character in the current location.
func _give_item(command: String) -> Array[String]:
	var item_id := _match_item(command, _inventory_of(PLAYER_ID))
	if item_id == "":
		return ["You don't have that."]

	var recipient_id := _match_character(command, get_visible_characters_for_location(current_location_id))
	if recipient_id == "":
		return ["Who do you want to give it to?"]

	_set_item_owner(item_id, recipient_id)
	var messages: Array[String] = [
		"You gave the %s to %s." % [
			items[item_id]["name"],
			characters[recipient_id]["display_name"],
		],
	]
	if _character_flag(recipient_id, "is_hungry") and _item_flag(item_id, "is_food"):
		messages.append_array(_eat_item(recipient_id, item_id))
	if _item_flag(item_id, "scent") and item_id == "rose":
		messages.append_array(_smell_rose(recipient_id))

	return messages


# Attacks a nearby character with a carried weapon.
func _attack(command: String) -> Array[String]:
	var victim_id := _match_character(command, get_visible_characters_for_location(current_location_id))
	if victim_id == "":
		return ["The character you want to attack was not matched."]

	var weapon_id := _match_weapon(command)
	if weapon_id == "":
		return ["You don't have a weapon."]
	if _character_flag(victim_id, "is_unconscious"):
		return ["%s is already unconscious." % characters[victim_id]["display_name"]]
	if _character_flag(victim_id, "is_dead") and victim_id != "ghost":
		return ["%s is already dead." % characters[victim_id]["display_name"]]

	var messages: Array[String] = [
		"You attacked %s with the %s." % [
			characters[victim_id]["display_name"],
			items[weapon_id]["name"],
		],
	]
	if _item_flag(weapon_id, "is_fragile"):
		items[weapon_id]["exists"] = false
		items[weapon_id]["owner"] = NO_OWNER
		items[weapon_id]["location"] = NO_LOCATION
		messages.append("The fragile weapon broke into pieces.")

	characters[victim_id]["flags"]["is_unconscious"] = true
	if victim_id == "guard":
		characters[victim_id]["flags"]["is_suspicious"] = false
	messages.append("%s was knocked unconscious." % characters[victim_id]["display_name"])

	for item_id in _inventory_of(victim_id).duplicate():
		_set_item_location(item_id, current_location_id)
		messages.append("%s dropped the %s." % [
			characters[victim_id]["display_name"],
			items[item_id]["name"],
		])

	return messages


# Unlocks the tower door with the brass key.
func _unlock_door() -> Array[String]:
	if not _item_exists_at_location("door", current_location_id):
		return ["I don't see a door here."]
	if not _item_flag("door", "is_locked"):
		return ["The door is already unlocked."]
	if not _has_inventory_item("key"):
		return ["You don't have a key."]

	items["door"]["flags"]["is_locked"] = false
	items["door"]["examine"] = "THE DOOR IS UNLOCKED."
	return ["You unlock the door with the brass key."]


# Banishes the dungeon ghost by reading the lit candle runes.
func _read_runes() -> Array[String]:
	if not _has_inventory_item("candle"):
		return ["I don't see a candle here."]
	if not _character_at_location("ghost", current_location_id):
		return ["There is no ghost here."]
	if not _item_flag("candle", "is_lit"):
		return ["The candle is not lit."]

	characters["ghost"]["flags"]["is_banished"] = true
	characters["ghost"]["location"] = NO_LOCATION
	for item_id in _inventory_of("ghost").duplicate():
		_set_item_location(item_id, current_location_id)

	return ["You read the runes on the candle and banish the ghost."]


# Handles a proposal and grants royalty through marriage.
func _propose(command: String) -> Array[String]:
	var propositioned_id := _match_character(command, get_visible_characters_for_location(current_location_id))
	if propositioned_id == "":
		var others := get_visible_characters_for_location(current_location_id)
		if others.size() == 1:
			propositioned_id = others[0]
	if propositioned_id == "":
		return ["Who do you want to propose to?"]
	if _character_flag(PLAYER_ID, "is_married"):
		return ["You are already married."]
	if _character_flag(propositioned_id, "is_married"):
		return ["%s is already married." % characters[propositioned_id]["display_name"]]
	if _character_property(PLAYER_ID, "emotional_state") != "happy":
		return ["You are not happy enough to propose."]
	if _character_property(propositioned_id, "emotional_state") != "happy":
		return ["%s is not happy enough to accept." % characters[propositioned_id]["display_name"]]

	characters[PLAYER_ID]["flags"]["is_married"] = true
	characters[propositioned_id]["flags"]["is_married"] = true
	if _character_flag(PLAYER_ID, "is_royal") or _character_flag(propositioned_id, "is_royal"):
		characters[PLAYER_ID]["flags"]["is_royal"] = true
		characters[propositioned_id]["flags"]["is_royal"] = true

	return ['%s says "Yes!" You are now married.' % characters[propositioned_id]["display_name"]]


# Crowns a royal character who is carrying the crown.
func _wear_crown(character_id: String) -> Array[String]:
	if not _character_has_item(character_id, "crown"):
		return ["You don't have a crown."]
	if not _character_flag(character_id, "is_royal"):
		if character_id == PLAYER_ID:
			return ["You are not royalty."]
		return ["%s is not royalty." % _capitalize_character_name(character_id)]

	characters[character_id]["flags"]["is_crowned"] = true
	if character_id == PLAYER_ID:
		return ["You place the crown upon your head."]
	return ["%s places the crown upon their head." % _capitalize_character_name(character_id)]


# Ends the game when a royal character sits on the throne.
func _sit_on_throne(character_id: String) -> Array[String]:
	if not _item_exists_at_location("throne", current_location_id):
		return ["There is no throne here."]
	if not _character_flag(character_id, "is_royal"):
		if character_id == PLAYER_ID:
			return ["You are not royalty."]
		return ["%s is not royalty." % _capitalize_character_name(character_id)]

	characters[character_id]["flags"]["is_reigning"] = true
	won = true
	game_over = true
	if character_id == PLAYER_ID:
		return [
			"You sit upon the throne of ACTION CASTLE!",
			"You now reign in ACTION CASTLE! You have won the game!",
		]
	var ruler := _capitalize_character_name(character_id)
	return [
		"%s sits upon the throne of ACTION CASTLE!" % ruler,
		"%s now reigns in ACTION CASTLE! %s has won the game!" % [ruler, ruler],
	]


# Eats a carried food item from a typed command.
func _eat_command(command: String) -> Array[String]:
	var item_id := _match_item(command, _inventory_of(PLAYER_ID))
	if item_id == "":
		return ["You don't have it."]
	if not _item_flag(item_id, "is_food"):
		return ["That's not edible."]
	return _eat_item(PLAYER_ID, item_id)


# Consumes an item and clears the character's hunger.
func _eat_item(character_id: String, item_id: String) -> Array[String]:
	items[item_id]["exists"] = false
	items[item_id]["owner"] = NO_OWNER
	items[item_id]["location"] = NO_LOCATION
	characters[character_id]["flags"]["is_hungry"] = false
	var message := "You eat the %s." % items[item_id]["name"]
	if character_id != PLAYER_ID:
		message = "%s eats the %s." % [
			_capitalize_character_name(character_id),
			items[item_id]["name"],
		]
	if _item_flag(item_id, "taste"):
		var taste := String(items[item_id]["flags"]["taste"])
		message += " It tastes %s" % taste
		if not taste.ends_with(".") and not taste.ends_with("!") and not taste.ends_with("?"):
			message += "."
	return [message]


# Lists carried items for the player.
func _describe_inventory() -> String:
	var inventory := _inventory_of(PLAYER_ID)
	if inventory.is_empty():
		return "Your inventory is empty."

	var lines: Array[String] = ["Your inventory contains:"]
	for item_id in inventory:
		lines.append("* %s" % items[item_id]["description"])
	return "\n".join(lines)


# Converts text into a direction if it names one.
func _direction_from_command(command: String) -> String:
	var normalized := command.strip_edges()
	if normalized.begins_with("go "):
		normalized = normalized.trim_prefix("go ").strip_edges()
	if DIRECTION_ALIASES.has(normalized):
		normalized = DIRECTION_ALIASES[normalized]

	var connections: Dictionary = locations[current_location_id]["connections"]
	if connections.has(normalized):
		return normalized
	return ""


# Finds the acting character named in a command, defaulting to the player.
func _character_from_command(command: String) -> String:
	for character_id in characters.keys():
		if character_id == PLAYER_ID:
			continue
		if command.contains(character_id) and _character_at_location(character_id, current_location_id):
			return character_id
	return PLAYER_ID


# Finds a visible character mentioned in the command.
func _match_character(command: String, candidate_ids: Array[String]) -> String:
	for character_id in candidate_ids:
		var display_name: String = String(characters[character_id]["display_name"]).to_lower()
		if command.contains(character_id) or command.contains(display_name):
			return character_id
	return ""


# Finds an item mentioned in the command from candidate item ids.
func _match_item(command: String, candidate_ids: Array[String]) -> String:
	for item_id in candidate_ids:
		if command.contains(item_id) or command.contains(String(items[item_id]["name"])):
			return item_id
	return ""


# Finds a carried weapon mentioned in the command or the first carried weapon.
func _match_weapon(command: String) -> String:
	for item_id in _inventory_of(PLAYER_ID):
		if _item_flag(item_id, "is_weapon") and (
			command.contains(item_id) or command.contains(String(items[item_id]["name"]))
		):
			return item_id
	for item_id in _inventory_of(PLAYER_ID):
		if _item_flag(item_id, "is_weapon"):
			return item_id
	return ""


# Returns item ids visible to a character.
func _items_in_scope(character_id: String) -> Array[String]:
	var scoped_items := get_visible_items_for_location(characters[character_id]["location"])
	scoped_items.append_array(_inventory_of(character_id))
	return scoped_items


# Returns item ids owned by a character.
func _inventory_of(character_id: String) -> Array[String]:
	var inventory: Array[String] = []
	for item_id in items.keys():
		if items[item_id]["exists"] and items[item_id]["owner"] == character_id:
			inventory.append(item_id)
	return inventory


# Checks whether the player has a specific inventory item.
func _has_inventory_item(item_id: String) -> bool:
	return _character_has_item(PLAYER_ID, item_id)


# Checks whether a character has a specific inventory item.
func _character_has_item(character_id: String, item_id: String) -> bool:
	return items.has(item_id) and items[item_id]["exists"] and items[item_id]["owner"] == character_id


# Checks whether an item exists at a location.
func _item_exists_at_location(item_id: String, location_id: String) -> bool:
	if not items.has(item_id):
		return false
	return items[item_id]["exists"] and items[item_id]["location"] == location_id


# Checks whether a character is currently in a location.
func _character_at_location(character_id: String, location_id: String) -> bool:
	return characters.has(character_id) and characters[character_id]["location"] == location_id


# Moves an item to a character inventory.
func _set_item_owner(item_id: String, character_id: String) -> void:
	items[item_id]["exists"] = true
	items[item_id]["owner"] = character_id
	items[item_id]["location"] = NO_LOCATION


# Moves an item into a location.
func _set_item_location(item_id: String, location_id: String) -> void:
	items[item_id]["exists"] = true
	items[item_id]["owner"] = NO_OWNER
	items[item_id]["location"] = location_id


# Reads an item flag as a truthy value.
func _item_flag(item_id: String, flag_name: String) -> bool:
	if not items.has(item_id):
		return false
	return _is_truthy(items[item_id]["flags"].get(flag_name, false))


# Reads a character flag as a truthy value.
func _character_flag(character_id: String, flag_name: String) -> bool:
	if not characters.has(character_id):
		return false
	return _is_truthy(characters[character_id]["flags"].get(flag_name, false))


# Reads a character flag value without coercion.
func _character_property(character_id: String, flag_name: String) -> Variant:
	if not characters.has(character_id):
		return null
	return characters[character_id]["flags"].get(flag_name)


# Reads a location flag as a truthy value.
func _location_flag(location_id: String, flag_name: String) -> bool:
	if not locations.has(location_id):
		return false
	return _is_truthy(locations[location_id]["flags"].get(flag_name, false))


# Converts common Variant values to notebook-style truthiness.
func _is_truthy(value: Variant) -> bool:
	if value == null:
		return false
	match typeof(value):
		TYPE_BOOL:
			return value
		TYPE_INT:
			return value != 0
		TYPE_FLOAT:
			return value != 0.0
		TYPE_STRING:
			return not String(value).is_empty()
		TYPE_STRING_NAME:
			return not String(value).is_empty()
		_:
			return true


# Checks all notebook-style route blocks.
func _is_blocked(location_id: String, direction: String) -> bool:
	if location_id == "drawbridge" and direction == "east":
		return _character_at_location("troll", "drawbridge") \
			and not _character_flag("troll", "is_dead") \
			and not _character_flag("troll", "is_unconscious") \
			and _character_flag("troll", "is_hungry")
	if location_id == "courtyard" and direction == "east":
		return _character_at_location("guard", "courtyard") \
			and not _character_flag("guard", "is_dead") \
			and not _character_flag("guard", "is_unconscious") \
			and _character_flag("guard", "is_suspicious")
	if location_id == "dungeon_stairs" and direction == "down":
		return _location_flag("dungeon_stairs", "is_dark") and not _has_lit_item_at(location_id)
	if location_id == "tower_stairs" and direction == "up":
		return _item_flag("door", "is_locked")
	return false


# Returns the notebook's route-block message.
func _block_description(location_id: String, direction: String) -> String:
	if location_id == "drawbridge" and direction == "east":
		return "A hungry troll blocks your way."
	if location_id == "courtyard" and direction == "east":
		return "The guard refuses to let you pass."
	if location_id == "dungeon_stairs" and direction == "down":
		return "It's too dark to go that way."
	if location_id == "tower_stairs" and direction == "up":
		return "The door ahead is locked."
	return "%s is blocked towards %s." % [locations[location_id]["name"], direction]


# Checks whether anyone at a location carries a lit item.
func _has_lit_item_at(location_id: String) -> bool:
	for character_id in characters.keys():
		if characters[character_id]["location"] != location_id:
			continue
		for item_id in _inventory_of(character_id):
			if _item_flag(item_id, "is_lit"):
				return true
	return false


# Capitalizes a character name for prose.
func _capitalize_character_name(character_id: String) -> String:
	if character_id == PLAYER_ID:
		return "You"
	return String(characters[character_id]["name"]).capitalize()


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
