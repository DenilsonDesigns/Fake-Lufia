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

func _process(_delta):
	if not visible:
		return
	if Input.is_action_just_pressed("ui_right"):
		selected_index += 1
		if selected_index >= icons.size():
			selected_index = 0
		_update_icon_selection()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index = (selected_index - 1 + icons.size()) % icons.size()
		_update_icon_selection()
	elif Input.is_action_just_pressed("ui_accept"):
		_emit_selected_action()

func _update_icon_selection():
	for i in range(icons.size()):
		icons[i].play("selected" if i == selected_index else "default")

func _emit_selected_action():
	var action = actions[selected_index]
	print("Selected action: ", action)
	emit_signal("action_selected", action)