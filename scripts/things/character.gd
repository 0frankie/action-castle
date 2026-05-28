extends "res://scripts/things/thing.gd"

## Actor object that can occupy locations and carry items.

var inventory: Dictionary = {}
var location: Variant = null


# Initializes character-specific state from world data.
func setup_character(character_id: String, data: Dictionary) -> void:
	setup_thing(character_id, data)


# Adds an item to this character's inventory.
func add_to_inventory(item: Variant) -> void:
	if item == null:
		return
	if item.location != null:
		item.location.remove_item(item)
	if item.owner != null and item.owner != self:
		item.owner.remove_from_inventory(item)
	inventory[item.id] = item
	item.owner = self
	item.location = null
	item.exists = true


# Removes an item from this character's inventory.
func remove_from_inventory(item: Variant) -> void:
	if item == null:
		return
	inventory.erase(item.id)
	if item.owner == self:
		item.owner = null


# Checks whether this character is carrying an item.
func is_in_inventory(item: Variant) -> bool:
	return item != null and inventory.has(item.id)
