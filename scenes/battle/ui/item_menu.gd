extends PanelContainer

@onready var item_container: VBoxContainer = $ItemContainer
@onready var amount_label: Label = $ItemContainer/HBoxContainer/VBoxContainer/Label

signal item_selected(item_name: String)
signal item_selection_cancelled

var potion_count := 0

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func open(potion_amount: int):
	potion_count = potion_amount
	amount_label.text = str(potion_amount)
	visible = true
	focus_mode = Control.FOCUS_ALL
	set_process_input(true)

	await get_tree().process_frame
	grab_focus()

func close():
	visible = false
	focus_mode = Control.FOCUS_NONE
	release_focus()
	set_process_input(false)

func _input(event):
	if not visible:
		return
	if event.is_action_pressed("ui_accept"):
		emit_signal("item_selected", "potion")
	elif event.is_action_pressed("ui_cancel"):
		emit_signal("item_selection_cancelled")
