extends SceneTree

const GAME_SCRIPT: GDScript = preload("res://scripts/action_castle_game.gd")

var _failed: bool = false


# Runs a complete winning route through the ported notebook rules.
func _init() -> void:
	var game: Variant = GAME_SCRIPT.new()
	var commands: Array[String] = [
		"get pole",
		"out",
		"pick rose",
		"smell rose",
		"south",
		"catch fish with pole",
		"north",
		"north",
		"up",
		"get branch",
		"down",
		"east",
		"give fish to troll",
		"east",
		"attack guard with branch",
		"get key",
		"east",
		"get candle",
		"light candle",
		"west",
		"down",
		"down",
		"read runes",
		"get crown",
		"up",
		"up",
		"up",
		"unlock door",
		"up",
		"give rose to princess",
		"propose to princess",
		"wear crown",
		"down",
		"down",
		"east",
		"east",
		"sit on throne",
	]

	for command in commands:
		var messages: Array[String] = game.run_command(command)
		print("> %s" % command)
		for message in messages:
			print(message)

	_expect(game.won, "The winning route should set won to true.")
	_expect(game.game_over, "The winning route should end the game.")
	quit(1 if _failed else 0)


# Records an expectation failure without stopping later checks.
func _expect(condition: bool, message: String) -> void:
	if condition:
		return
	_failed = true
	push_error(message)
