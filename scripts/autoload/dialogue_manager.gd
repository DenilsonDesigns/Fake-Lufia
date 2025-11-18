extends Node

var _lines: Array[Dictionary] = []
var _index: int = 0
var _actors: Dictionary = {}
var _active: bool = false
var _dialogue_box: Node = null

signal conversation_finished(actor: Node)

var SpeechBoxScene = preload("res://scenes/ui/speech_box.tscn")

var current_actor: Node = null

func start(conversation: ConversationResource, actors: Dictionary) -> void:
	if _active:
		return

	current_actor = actors.get("npc")

	_lines = conversation.lines
	_actors = actors
	_index = 0
	_active = true

	_dialogue_box = SpeechBoxScene.instantiate()
	get_tree().root.add_child(_dialogue_box)

	_show_current_line()

func next() -> void:
	if not _active:
		return

	_index += 1
	if _index >= _lines.size():
		_end_conversation()
		return

	_show_current_line()

func _show_current_line() -> void:
	var entry: Dictionary = _lines[_index]
	var actor_key: String = entry["actor"]
	var actor_node: Node = _actors.get(actor_key)

	if _dialogue_box and actor_node:
		_dialogue_box.set_speaker(actor_node)
		_dialogue_box.set_text(entry["text"])

func _end_conversation() -> void:
	if _dialogue_box:
		_dialogue_box.queue_free()
		_dialogue_box = null

	conversation_finished.emit(current_actor)
	_active = false
	_lines = []
	_index = 0
	_actors = {}

func is_active() -> bool:
	return _active
