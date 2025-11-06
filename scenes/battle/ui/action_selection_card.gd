extends PanelContainer

@onready var attack_icon: AnimatedSprite2D = %AttackIcon
@onready var defend_icon: AnimatedSprite2D = %DefendIcon
@onready var item_icon: AnimatedSprite2D = %ItemIcon

var icons: Array[AnimatedSprite2D]
var selected_index := 0

func _ready():
	icons = [attack_icon, defend_icon, item_icon]
	_update_icon_selection()

func _process(_delta):
	if Input.is_action_just_pressed("ui_right"):
		selected_index += 1
		if selected_index >= icons.size():
			selected_index = 0
		_update_icon_selection()
	elif Input.is_action_just_pressed("ui_left"):
		selected_index -= 1
		if selected_index < 0:
			selected_index = icons.size() - 1
		_update_icon_selection()

func _update_icon_selection():
	for i in range(icons.size()):
		if i == selected_index:
			icons[i].play("selected")
		else:
			icons[i].play("default")
