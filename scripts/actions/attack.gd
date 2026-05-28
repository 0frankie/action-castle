extends "res://scripts/actions/action.gd"

## Attacks a nearby character with a carried weapon.

var victim: Variant = null
var weapon: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "attack"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["hit", "hits"]


# Parses victim and weapon from the command.
func _prepare() -> void:
	character = game.player
	victim = parser.match_character(command, character.location.characters)
	if victim == character:
		victim = null
	weapon = _match_weapon(command)


# Checks the combat preconditions.
func _check_preconditions() -> bool:
	if victim == null:
		fail("The character you want to attack was not matched.")
		return false
	if weapon == null:
		fail("You don't have a weapon.")
		return false
	if victim.property_truthy("is_unconscious"):
		fail("%s is already unconscious." % victim.display_name)
		return false
	if victim.property_truthy("is_dead") and victim.id != "ghost":
		fail("%s is already dead." % victim.display_name)
		return false
	return true


# Knocks the victim unconscious and drops their inventory.
func _apply_effects() -> void:
	ok("You attacked %s with the %s." % [victim.display_name, weapon.name])
	if weapon.property_truthy("is_fragile"):
		character.remove_from_inventory(weapon)
		weapon.remove_from_world()
		ok("The fragile weapon broke into pieces.")

	victim.set_property("is_unconscious", true)
	if victim.id == "guard":
		victim.set_property("is_suspicious", false)
	ok("%s was knocked unconscious." % victim.display_name)

	var dropped_items: Array = victim.inventory.values()
	for item in dropped_items:
		victim.remove_from_inventory(item)
		character.location.add_item(item)
		ok("%s dropped the %s." % [victim.display_name, item.name])


# Finds a named carried weapon or the first carried weapon.
func _match_weapon(command_text: String) -> Variant:
	for item_id in character.inventory.keys():
		var item: Variant = character.inventory[item_id]
		if item.property_truthy("is_weapon") and (
			command_text.contains(item.id) or command_text.contains(String(item.name))
		):
			return item
	for item_id in character.inventory.keys():
		var item: Variant = character.inventory[item_id]
		if item.property_truthy("is_weapon"):
			return item
	return null
