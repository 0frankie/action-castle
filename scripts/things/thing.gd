extends RefCounted

## Base object shared by locations, items, and characters.

var id: String = ""
var name: String = ""
var display_name: String = ""
var description: String = ""
var properties: Dictionary = {}


# Initializes shared identity, description, and properties.
func setup_thing(thing_id: String, data: Dictionary) -> void:
	id = thing_id
	name = data["name"]
	display_name = data.get("display_name", name)
	description = data.get("description", "")
	properties = data.get("flags", {}).duplicate(true)


# Stores an arbitrary property value.
func set_property(property_name: String, value: Variant) -> void:
	properties[property_name] = value


# Reads an arbitrary property value.
func get_property(property_name: String, default_value: Variant = false) -> Variant:
	return properties.get(property_name, default_value)


# Checks whether a property exists on this thing.
func has_property(property_name: String) -> bool:
	return properties.has(property_name)


# Reads a property using the Python game's truthiness rules.
func property_truthy(property_name: String) -> bool:
	return is_truthy(properties.get(property_name, false))


# Converts common Variant values to text-adventure-style truthiness.
func is_truthy(value: Variant) -> bool:
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
