extends "res://scripts/actions/action.gd"

## Ends the game when a royal character sits on the throne.

var throne: Variant = null


# Returns the canonical command name for this action.
func action_name() -> String:
	return "sit on throne"


# Parses the acting character and local throne.
func _prepare() -> void:
	character = parser.get_character(command)
	throne = character.location.get_item("throne") if character.location != null else null


# Checks that a royal character is at the throne.
func _check_preconditions() -> bool:
	if throne == null:
		fail("There is no throne here.")
		return false
	if not character.property_truthy("is_royal"):
		if character == game.player:
			fail("You are not royalty.")
		else:
			fail("%s is not royalty." % String(character.name).capitalize())
		return false
	return true


# Marks the actor as reigning and wins the game.
func _apply_effects() -> void:
	character.set_property("is_reigning", true)
	game.won = true
	game.game_over = true
	if character == game.player:
		ok("You sit upon the throne of ACTION CASTLE!")
		ok("You now reign in ACTION CASTLE! You have won the game!")
		return
	var ruler := String(character.name).capitalize()
	ok("%s sits upon the throne of ACTION CASTLE!" % ruler)
	ok("%s now reigns in ACTION CASTLE! %s has won the game!" % [ruler, ruler])
