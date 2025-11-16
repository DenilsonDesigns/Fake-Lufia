extends PanelContainer

@onready var speaker_name: Label = $VBoxContainer/SpeakerName
@onready var content: Label = $VBoxContainer/Content

var target: Node = null
var y_offset: float = -32.0 # adjust to sit above the NPC/player

func set_speaker(speaker_node: Node) -> void:
	target = speaker_node
	if "display_name" in target:
		speaker_name.text = target.display_name
	else:
		speaker_name.text = target.name
	_update_position()

func set_text(text: String) -> void:
	content.text = text

func _process(_delta: float) -> void:
	if target:
		_update_position()

func _update_position() -> void:
	if not target:
		return

	var cam: Camera2D = get_viewport().get_camera_2d()
	if cam == null:
		return

	var screen_pos = target.global_position - cam.global_position + cam.get_position()
	global_position = screen_pos + Vector2(0, y_offset)
