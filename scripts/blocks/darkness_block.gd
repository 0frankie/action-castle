extends "res://scripts/blocks/block.gd"

## Blocks a dark passage until someone present carries a lit item.

var location: Variant = null


# Connects this blocker to a dark location.
func setup(location_ref: Variant) -> void:
	setup_block("Darkness blocks your way", "It's too dark to go that way.")
	location = location_ref


# Checks whether darkness still blocks movement.
func is_blocked() -> bool:
	if location == null:
		return false
	if not location.property_truthy("is_dark"):
		return false
	return not _has_lit_item()


# Checks whether anyone at this location carries a lit item.
func _has_lit_item() -> bool:
	for character_id in location.characters.keys():
		var character: Variant = location.characters[character_id]
		for item_id in character.inventory.keys():
			var item: Variant = character.inventory[item_id]
			if item.property_truthy("is_lit"):
				return true
	return false
