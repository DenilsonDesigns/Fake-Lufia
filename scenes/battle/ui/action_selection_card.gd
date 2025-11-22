extends PanelContainer

@onready var attack_icon: AnimatedSprite2D = %AttackIcon
@onready var defend_icon: AnimatedSprite2D = %DefendIcon
@onready var item_icon: AnimatedSprite2D = %ItemIcon

signal action_selected(action: String)

var icons: Array[AnimatedSprite2D]
var selected_index := 0

var actions := ["attack", "defend", "item"]

func _ready():
	icons = [attack_icon, defend_icon, item_icon]
	_update_icon_selection()
	focus_mode = Control.FOCUS_ALL
	grab_focus()

func _unhandled_key_input(event: InputEvent) -> void:
	if not visible:
		return
	if not has_focus():
		return
	
	if event.is_action_pressed("ui_right"):
		selected_index = (selected_index + 1) % icons.size()
		_update_icon_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_left"):
		selected_index = (selected_index - 1 + icons.size()) % icons.size()
		_update_icon_selection()
		get_viewport().set_input_as_handled()

	elif event.is_action_pressed("ui_accept"):
		_emit_selected_action()
		get_viewport().set_input_as_handled()

func _update_icon_selection():
	for i in range(icons.size()):
		icons[i].play("selected" if i == selected_index else "default")

func _emit_selected_action():
	var action = actions[selected_index]
	print("Selected action: ", action)
	emit_signal("action_selected", action)