class_name LocationNode
extends Node2D

## Editor-visible room container that binds a scene node to a game location id.

const PLAYER_STOP_MARKER_NAME: String = "PlayerStop"
const PLAYER_STOP_MARKER_GROUP: StringName = &"location_player_stops"
const TRAVEL_MARKER_GROUP: StringName = &"location_travel_markers"

@export var location_id: String = ""

func _ready() -> void:
	var marker := get_player_stop_marker()
	if marker != null and not marker.is_in_group(PLAYER_STOP_MARKER_GROUP):
		marker.add_to_group(PLAYER_STOP_MARKER_GROUP)

	for child in get_children():
		if child is Marker2D and String(child.name).begins_with("Exit"):
			child.add_to_group(TRAVEL_MARKER_GROUP)


func get_player_stop_marker() -> Marker2D:
	return get_node_or_null(PLAYER_STOP_MARKER_NAME) as Marker2D


func get_player_stop_position() -> Vector2:
	var marker := get_player_stop_marker()
	if marker == null:
		return global_position
	return marker.global_position


func get_travel_marker(direction: String) -> Marker2D:
	var marker_name := "Exit%s" % direction.capitalize()
	return get_node_or_null(marker_name) as Marker2D
