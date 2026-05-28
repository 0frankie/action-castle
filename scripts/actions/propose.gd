extends "res://scripts/actions/action.gd"

## Proposes marriage to a nearby character.

var propositioned: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "propose"


# Returns alternate command names for this action.
func action_aliases() -> Array[String]:
	return ["propose marriage"]


# Parses the nearby character being propositioned.
func _prepare() -> void:
	character = game.player
	propositioned = parser.match_character(command, character.location.characters)
	if propositioned == character:
		propositioned = null
	if propositioned == null:
		var others: Array[Variant] = []
		for character_id in character.location.characters.keys():
			var other: Variant = character.location.characters[character_id]
			if other != character:
				others.append(other)
		if others.size() == 1:
			propositioned = others[0]


# Checks marriage and emotional-state preconditions.
func _check_preconditions() -> bool:
	if propositioned == null:
		fail("Who do you want to propose to?")
		return false
	if character.property_truthy("is_married"):
		fail("You are already married.")
		return false
	if propositioned.property_truthy("is_married"):
		fail("%s is already married." % propositioned.display_name)
		return false
	if character.get_property("emotional_state", "") != "happy":
		fail("You are not happy enough to propose.")
		return false
	if propositioned.get_property("emotional_state", "") != "happy":
		fail("%s is not happy enough to accept." % propositioned.display_name)
		return false
	return true


# Marries the pair and grants royalty when either spouse is royal.
func _apply_effects() -> void:
	character.set_property("is_married", true)
	propositioned.set_property("is_married", true)
	if character.property_truthy("is_royal") or propositioned.property_truthy("is_royal"):
		character.set_property("is_royal", true)
		propositioned.set_property("is_royal", true)
	ok('%s says "Yes!" You are now married.' % propositioned.display_name)
