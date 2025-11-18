extends PanelContainer

@export var price := 50
@export var max_amount := 99

@onready var amount_label: Label = $HBoxContainer/VBoxContainer/Label
@onready var up_arrow = $HBoxContainer/VBoxContainer/ArrowUpContainer/ArrowUp
@onready var down_arrow = $HBoxContainer/VBoxContainer/ArrowDownContainer/ArrowDown

var amount := 1

func _ready():
	amount_label.text = str(amount)
	set_process_input(false)

func open():
	visible = true
	amount = 1
	amount_label.text = "1"
	set_process_input(true)

func close():
	visible = false
	set_process_input(false)

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

	if GameState.gold >= total_cost:
		GameState.gold -= total_cost
		GameState.add_item("potion", amount)
		close()
		# optional: show a “Thank you!” dialogue
	else:
		# show error text?
		close()