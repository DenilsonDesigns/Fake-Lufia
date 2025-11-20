extends PanelContainer

@export var price := 50
@export var max_amount := 99

@onready var amount_label: Label = $HBoxContainer/VBoxContainer/Label
@onready var up_arrow = $HBoxContainer/VBoxContainer/ArrowUpContainer/ArrowUp
@onready var down_arrow = $HBoxContainer/VBoxContainer/ArrowDownContainer/ArrowDown

var amount := 1

func _ready():
	focus_mode = Control.FOCUS_ALL
	grab_focus()
	amount_label.text = str(amount)
	set_process_input(true)

func open():
	visible = true
	# @NOTE: super hacky but just doing it like this for learning project
	# in real project I would break this shop_menu out of the scene its in
	# and put it in a UI layer.
	z_index = 100
	grab_focus()

	amount = 1
	amount_label.text = "1"

	set_process_input(true)
	GameState.in_menu = true
	GameState.ui_blocked = true

func close():
	visible = false
	set_process_input(false)
	GameState.in_menu = false
	GameState.ui_blocked = false

	var player = get_tree().get_first_node_in_group("player")
	if player:
		player.interact_target = null

func _input(event):
	if not visible:
		return

	if event.is_action_pressed("ui_up"):
		amount = clamp(amount + 1, 1, max_amount)
		amount_label.text = str(amount)

	elif event.is_action_pressed("ui_down"):
		amount = clamp(amount - 1, 1, max_amount)
		amount_label.text = str(amount)

	elif event.is_action_pressed("ui_accept"):
		_confirm_purchase()

	elif event.is_action_pressed("ui_cancel"):
		close()

func _confirm_purchase():
	var total_cost = amount * price

	if GameState.get_gold() >= total_cost:
		GameState.set_gold(total_cost)
		GameState.add_item("potion", amount)
		close()
	else:
		close()
