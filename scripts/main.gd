extends Node2D

## Scene controller for the editor-built Action Castle node tree.

const ITEM_NODE_IDS: Dictionary = {
	"Lamp": "lamp",
	"Pole": "pole",
	"Branch": "branch",
	"Candle": "candle",
	"Pond": "pond",
	"Rosebush": "rosebush",
	"Throne": "throne",
	"Door": "door",
	"Key": "key",
	"Sword": "sword",
	"Crown": "crown",
	"Fish": "fish",
	"Rose": "rose",
}

const CHARACTER_NODE_IDS: Dictionary = {
	"Troll": "troll",
	"Guard": "guard",
	"Princess": "princess",
	"Ghost": "ghost",
}

const ITEM_SLOT_POSITIONS: Array[Vector2] = [
	Vector2(-470.0, 145.0),
	Vector2(-250.0, 165.0),
	Vector2(-30.0, 155.0),
	Vector2(190.0, 165.0),
	Vector2(410.0, 145.0),
]

const CHARACTER_SLOT_POSITIONS: Array[Vector2] = [
	Vector2(-150.0, 25.0),
	Vector2(120.0, 25.0),
	Vector2(360.0, 45.0),
]

const MAX_HISTORY_TURNS: int = 10
const ACTION_CASTLE_GAME_SCRIPT: GDScript = preload("res://scripts/action_castle_game.gd")

var _game: Variant
var _location_nodes: Dictionary = {}
var _item_nodes: Dictionary = {}
var _character_nodes: Dictionary = {}
var _turns: Array[Array] = []

@onready var _locations_root: Node2D = $World/Locations
@onready var _entity_pool: Node2D = $World/EntityPool
@onready var _location_title: Label = $CanvasLayer/GameUi/TopBar/LocationTitle
@onready var _inventory_label: Label = $CanvasLayer/GameUi/TopBar/InventoryLabel
@onready var _story_scroll: ScrollContainer = $CanvasLayer/GameUi/StoryPanel/StoryScroll
@onready var _story_log: RichTextLabel = $CanvasLayer/GameUi/StoryPanel/StoryScroll/StoryLog
@onready var _command_input: LineEdit = $CanvasLayer/GameUi/CommandBar/CommandInput
@onready var _command_button: Button = $CanvasLayer/GameUi/CommandBar/SubmitButton
@onready var _restart_button: Button = $CanvasLayer/GameUi/CommandBar/RestartButton


# Initializes the game model, entity lookup tables, and first room view.
func _ready() -> void:
	_game = ACTION_CASTLE_GAME_SCRIPT.new()
	_collect_location_nodes()
	_collect_entity_nodes(_locations_root)
	_collect_entity_nodes(_entity_pool)
	_wire_ui()
	_start_turn(_game.describe_current_state())
	_refresh()
	_command_input.grab_focus()


# Submits the line edit when the player presses Enter.
func _wire_ui() -> void:
	_command_input.text_submitted.connect(_on_command_submitted)
	_command_button.pressed.connect(_on_submit_button_pressed)
	_restart_button.pressed.connect(_on_restart_pressed)


# Captures typed commands from the input field.
func _on_command_submitted(command: String) -> void:
	_submit_command(command)


# Captures the explicit submit button.
func _on_submit_button_pressed() -> void:
	_submit_command(_command_input.text)


# Restarts the model and refreshes every editor-backed node.
func _on_restart_pressed() -> void:
	_game.reset()
	_turns.clear()
	_start_turn("The story begins again.")
	_start_turn(_game.describe_current_state())
	_refresh()
	_command_input.grab_focus()


# Runs a command, records the result, and redraws the scene.
func _submit_command(command: String) -> void:
	var cleaned_command := command.strip_edges()
	if cleaned_command.is_empty():
		return

	_command_input.clear()
	_start_turn("> %s" % cleaned_command)
	var messages: Array[String] = _game.run_command(cleaned_command)
	for message in messages:
		_append_to_current_turn(message)
	_refresh()
	_command_input.grab_focus()


# Finds all LocationNode children by their exported ids.
func _collect_location_nodes() -> void:
	_location_nodes.clear()
	for child in _locations_root.get_children():
		var location_id := String(child.get("location_id"))
		if location_id != "":
			_location_nodes[location_id] = child


# Recursively finds item and character nodes placed in the editor tree.
func _collect_entity_nodes(root: Node) -> void:
	if ITEM_NODE_IDS.has(root.name):
		_item_nodes[ITEM_NODE_IDS[root.name]] = root
	if CHARACTER_NODE_IDS.has(root.name):
		_character_nodes[CHARACTER_NODE_IDS[root.name]] = root

	for child in root.get_children():
		_collect_entity_nodes(child)


# Redraws the room visibility, entity positions, text, and command buttons.
func _refresh() -> void:
	var snapshot: Dictionary = _game.get_state_snapshot()
	var current_location_id: String = snapshot["current_location_id"]
	for location_id in _location_nodes.keys():
		_location_nodes[location_id].visible = location_id == current_location_id

	_refresh_entities(snapshot)
	_refresh_text()


# Places visible item and character nodes under the active room containers.
func _refresh_entities(snapshot: Dictionary) -> void:
	for item_id in _item_nodes.keys():
		_item_nodes[item_id].visible = false
	for character_id in _character_nodes.keys():
		_character_nodes[character_id].visible = false

	var current_location_id: String = snapshot["current_location_id"]
	var item_ids: Array[String] = _game.get_visible_items_for_location(current_location_id)
	for index in range(item_ids.size()):
		_place_item_node(item_ids[index], current_location_id, index)

	var character_ids: Array[String] = _game.get_visible_characters_for_location(
		current_location_id
	)
	for index in range(character_ids.size()):
		_place_character_node(character_ids[index], current_location_id, index)


# Moves an item display node into the active room's Items container.
func _place_item_node(item_id: String, location_id: String, index: int) -> void:
	if not _item_nodes.has(item_id):
		return
	var parent := _items_container_for(location_id)
	if parent == null:
		return

	var item_node := _item_nodes[item_id] as Node2D
	if item_node.get_parent() != parent:
		item_node.reparent(parent, false)
	item_node.position = ITEM_SLOT_POSITIONS[index % ITEM_SLOT_POSITIONS.size()]
	item_node.visible = true
	_set_entity_label(item_node, _game.get_item_label(item_id))


# Moves a character display node into the active room's Characters container.
func _place_character_node(character_id: String, location_id: String, index: int) -> void:
	if not _character_nodes.has(character_id):
		return
	var parent := _characters_container_for(location_id)
	if parent == null:
		return

	var character_node := _character_nodes[character_id] as Node2D
	if character_node.get_parent() != parent:
		character_node.reparent(parent, false)
	character_node.position = CHARACTER_SLOT_POSITIONS[index % CHARACTER_SLOT_POSITIONS.size()]
	character_node.visible = true
	_set_entity_label(character_node, _game.get_character_label(character_id))


# Updates the visible label on an item or character display node.
func _set_entity_label(entity_node: Node2D, label_text: String) -> void:
	var label := entity_node.get_node_or_null("Label") as Label
	if label == null:
		return
	label.text = label_text


# Updates title, inventory, and story log text.
func _refresh_text() -> void:
	var location: Dictionary = _game.get_current_location()
	_location_title.text = location["name"]

	var inventory_ids: Array[String] = _game.get_inventory()
	if inventory_ids.is_empty():
		_inventory_label.text = "Inventory: empty"
	else:
		var labels: Array[String] = []
		for item_id in inventory_ids:
			labels.append(_game.get_item_label(item_id))
		_inventory_label.text = "Inventory: %s" % ", ".join(labels)

	_story_log.text = _format_history()
	_scroll_story_to_bottom()


# Joins all turn blocks into display text, styling user commands distinctly.
func _format_history() -> String:
	var blocks: PackedStringArray = []
	for turn in _turns:
		var styled_lines: PackedStringArray = []
		for line in turn:
			styled_lines.append(_style_line(line))
		blocks.append("\n".join(styled_lines))
	return "\n\n".join(blocks)


# Wraps user-input command lines in bbcode so they stand out from responses.
func _style_line(line: String) -> String:
	if line.begins_with("> "):
		return "[b][color=#7ec8ff]%s[/color][/b]" % line
	return line


# Scrolls the story panel to the latest content after layout settles.
func _scroll_story_to_bottom() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	_story_scroll.scroll_vertical = int(_story_scroll.get_v_scroll_bar().max_value)


# Starts a new turn block and trims oldest turns past the cap.
func _start_turn(first_line: String) -> void:
	_turns.append([first_line])
	while _turns.size() > MAX_HISTORY_TURNS:
		_turns.pop_front()


# Appends a line to the latest turn, starting one if history is empty.
func _append_to_current_turn(line: String) -> void:
	if _turns.is_empty():
		_start_turn(line)
		return
	var current_turn: Array = _turns[_turns.size() - 1]
	current_turn.append(line)


# Gets the Items container for a location node.
func _items_container_for(location_id: String) -> Node2D:
	if not _location_nodes.has(location_id):
		return null
	return _location_nodes[location_id].get_node_or_null("Items") as Node2D


# Gets the Characters container for a location node.
func _characters_container_for(location_id: String) -> Node2D:
	if not _location_nodes.has(location_id):
		return null
	return _location_nodes[location_id].get_node_or_null("Characters") as Node2D
