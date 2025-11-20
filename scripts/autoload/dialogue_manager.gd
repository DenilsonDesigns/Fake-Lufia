extends Node

signal conversation_finished(actor: Node)

var _lines: Array[Dictionary] = []
var _index: int = 0
var _actors: Dictionary = {}
var _active: bool = false
var _dialogue_box: Node = null

var SpeechBoxScene := preload("res://scenes/ui/speech_box.tscn")

var current_actor: Node = null
var _actor_tree_exited_connected: bool = false

func start(conversation: ConversationResource, actors: Dictionary) -> void:
	if _active or GameState.ui_blocked:
		return

	# Defensive: ensure we actually have a resource
	if not conversation:
		push_error("DialogueManager.start called with null conversation")
		return

	# Lock UI globally so nothing else can start
	GameState.ui_blocked = true

	current_actor = actors.get("npc")
	_lines = conversation.lines
	_actors = actors
	_index = 0
	_active = true

	# Create UI
	_dialogue_box = SpeechBoxScene.instantiate()
	get_tree().root.add_child(_dialogue_box)

	# Connect to actor leaving the scene so we can auto-cancel
	_actor_tree_exited_connected = false
	if is_instance_valid(current_actor):
		# connect to tree_exited to detect when this node is removed/unloaded
		current_actor.connect("tree_exited", Callable(self, "_on_actor_tree_exited"))
		_actor_tree_exited_connected = true

	_show_current_line()

func next() -> void:
	if not _active:
		return

	# safety: guard _lines
	if _lines == null:
		force_cancel()
		return

	_index += 1
	if _index >= _lines.size():
		_end_conversation()
		return

	_show_current_line()

func _show_current_line() -> void:
	# Safety guard: ensure lines exist and actor references are valid
	if _lines == null or _index < 0 or _index >= _lines.size():
		force_cancel()
		return

	var entry: Dictionary = _lines[_index]
	var actor_key: String = entry.get("actor", "")
	var actor_node: Node = _actors.get(actor_key, null)

	# If actor_node is invalid or freed, cancel the dialogue
	if actor_node == null or not is_instance_valid(actor_node):
		force_cancel()
		return

	# Finally set the UI
	if _dialogue_box:
		_dialogue_box.set_speaker(actor_node)
		_dialogue_box.set_text(str(entry.get("text", "")))

func _end_conversation() -> void:
	# normal end-of-conversation cleanup
	if _dialogue_box:
		_dialogue_box.queue_free()
		_dialogue_box = null

	# emit who finished
	emit_signal("conversation_finished", current_actor)

	# reset state
	_active = false
	_lines = []
	_index = 0
	_actors = {}

	# unlock UI
	GameState.ui_blocked = false

	# disconnect actor signal if needed
	_disconnect_actor_tree_exited()

	# clear current actor
	current_actor = null

func force_cancel() -> void:
	# immediate hard cancel (for actor leaving, scene unload)
	if _dialogue_box:
		_dialogue_box.queue_free()
		_dialogue_box = null

	_active = false
	_lines = []
	_index = 0
	_actors = {}
	GameState.ui_blocked = false

	_disconnect_actor_tree_exited()
	current_actor = null

func _on_actor_tree_exited() -> void:
	# actor left the tree (scene unloaded) — force cancel without emitting finished
	force_cancel()

func _disconnect_actor_tree_exited() -> void:
	if _actor_tree_exited_connected and current_actor and is_instance_valid(current_actor):
		# safe-disconnect (may already be disconnected if actor freed)
		if current_actor.is_connected("tree_exited", Callable(self, "_on_actor_tree_exited")):
			current_actor.disconnect("tree_exited", Callable(self, "_on_actor_tree_exited"))
	_actor_tree_exited_connected = false

func is_active() -> bool:
	return _active
