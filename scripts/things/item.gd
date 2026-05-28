extends "res://scripts/things/thing.gd"

## Inventory and location object used by Action Castle.

var examine_text: String = ""
var gettable: bool = true
var exists: bool = true
var command_hints: Array[String] = []
var location: Variant = null
var owner: Variant = null


# Initializes item-specific state from world data.
func setup_item(item_id: String, data: Dictionary) -> void:
	setup_thing(item_id, data)
	examine_text = data.get("examine", description)
	gettable = data.get("gettable", true)
	exists = data.get("exists", true)
	command_hints.assign(data.get("hints", []))


# Adds a command hint shown by room descriptions.
func add_command_hint(command_hint: String) -> void:
	command_hints.append(command_hint)


# Returns command hints shown by room descriptions.
func get_command_hints() -> Array[String]:
	return command_hints.duplicate()


# Clears owner and location references when the item leaves play.
func remove_from_world() -> void:
	exists = false
	location = null
	owner = null
