extends Node

var selan: Selan

func level_swap(selan_to_stash: Selan, new_level_string: String) -> void:
	stash_selan(selan_to_stash)
	get_tree().change_scene_to_file(new_level_string)
	drop_selan()

func stash_selan(selan_to_stash: Selan) -> void:
	selan = selan_to_stash
	selan.get_parent().remove_child(selan)

func drop_selan() -> void:
	await get_tree().create_timer(0).timeout
	var parent := get_tree().current_scene

	remove_existing_selan(parent)

	parent.add_child(selan)
	selan.owner = parent

	for transition_door: TransitionDoor in get_tree().get_nodes_in_group("TransitionDoors"):
		if transition_door.connection == selan.last_door_connection:
			selan.global_position = transition_door.drop_point.global_position
			selan.reset_door_cooldown()
			break

func remove_existing_selan(parent: Node) -> void:
	var existing_selan := parent.get_node_or_null("Selan")
	if existing_selan:
		parent.remove_child(existing_selan)
