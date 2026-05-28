extends "res://scripts/actions/action.gd"

## Catches a fish from the pond when the player uses the pole.

var pond: Variant = null
var fish: Variant = null
var pole: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "catch fish"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["go fishing"]


# Parses pond, fish, and pole references.
func _prepare() -> void:
	character = game.player
	pond = character.location.get_item("pond") if character.location != null else null
	fish = game.items["fish"]
	pole = character.inventory.get("pole", null)


# Checks whether the player can catch a fish.
func _check_preconditions() -> bool:
	if pond == null:
		fail("There's no pond here.")
		return false
	if not pond.property_truthy("has_fish"):
		fail("The pond has no fish.")
		return false
	return true


# Creates the fish item and puts it in inventory.
func _apply_effects() -> void:
	if not command.contains("with pole") or pole == null:
		fail("You reach into the pond, but the fish are too fast.")
		return
	pond.set_property("has_fish", false)
	character.add_to_inventory(fish)
	ok("You dip the hook into the pond and catch a fish.")
