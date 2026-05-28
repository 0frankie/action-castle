extends "res://scripts/things/thing.gd"

## Room node in the text-adventure world graph.

var connections: Dictionary = {}
var blocks: Dictionary = {}
var items: Dictionary = {}
var characters: Dictionary = {}
var has_been_visited: bool = false


# Initializes location-specific state from world data.
func setup_location(location_id: String, data: Dictionary) -> void:
	setup_thing(location_id, data)


# Adds a connection and mirrors cardinal directions like the Python library.
func add_connection(direction: String, connected_location: Variant) -> void:
	var normalized_direction := direction.to_lower()
	connections[normalized_direction] = connected_location
	var reverse_direction := _reverse_direction(normalized_direction)
	if reverse_direction != "" and not connected_location.connections.has(reverse_direction):
		connected_location.connections[reverse_direction] = self


# Returns the connected location in a direction.
func get_connection(direction: String) -> Variant:
	return connections.get(direction, null)


# Places an item at this location.
func add_item(item: Variant) -> void:
	if item == null:
		return
	if item.owner != null:
		item.owner.remove_from_inventory(item)
	items[item.id] = item
	item.location = self
	item.owner = null
	item.exists = true


# Removes an item from this location.
func remove_item(item: Variant) -> void:
	if item == null:
		return
	items.erase(item.id)
	if item.location == self:
		item.location = null


# Places a character at this location.
func add_character(character: Variant) -> void:
	if character == null:
		return
	if character.location != null and character.location != self:
		character.location.remove_character(character)
	characters[character.id] = character
	character.location = self


# Removes a character from this location.
func remove_character(character: Variant) -> void:
	if character == null:
		return
	characters.erase(character.id)
	if character.location == self:
		character.location = null


# Checks whether a character or item is present here.
func here(thing: Variant) -> bool:
	if thing == null:
		return false
	if "location" in thing:
		return thing.location == self
	return false


# Returns an item by id or name.
func get_item(item_name: String) -> Variant:
	for item_id in items.keys():
		var item: Variant = items[item_id]
		if item.id == item_name or item.name == item_name:
			return item
	return null


# Adds a movement blocker for a direction.
func add_block(direction: String, block: Variant) -> void:
	blocks[direction.to_lower()] = block


# Checks whether a direction is blocked.
func is_blocked(direction: String) -> bool:
	var block: Variant = blocks.get(direction.to_lower(), null)
	return block != null and block.is_blocked()


# Returns a blocker's message for a direction.
func get_block_description(direction: String) -> String:
	var block: Variant = blocks.get(direction.to_lower(), null)
	if block == null:
		return ""
	return block.blocked_description


# Maps automatic reverse directions.
func _reverse_direction(direction: String) -> String:
	match direction:
		"north":
			return "south"
		"south":
			return "north"
		"east":
			return "west"
		"west":
			return "east"
		"up":
			return "down"
		"down":
			return "up"
		"in":
			return "out"
		"out":
			return "in"
		"inside":
			return "outside"
		"outside":
			return "inside"
	return ""
