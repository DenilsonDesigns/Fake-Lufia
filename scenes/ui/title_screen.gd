extends Control

@onready var pointer := $Menu/Pointer
@onready var vbox_container: VBoxContainer = $Menu/VBoxContainer

var buttons: Array[Button] = []
var selected_index := 0

func _ready():
	for child in vbox_container.get_children():
		if child is Button:
			buttons.append(child)

	update_pointer_position()


func _input(event):
	if event.is_action_pressed("ui_down"):
		selected_index = (selected_index + 1) % buttons.size()
		update_pointer_position()

	if event.is_action_pressed("ui_up"):
		selected_index = (selected_index - 1 + buttons.size()) % buttons.size()
		update_pointer_position()

	if event.is_action_pressed("ui_accept"):
		var btn = buttons[selected_index]
		match btn.name:
			"Start":
				_on_start_pressed()
			"Quit":
				_on_quit_pressed()

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_pressed():
	get_tree().quit()


func update_pointer_position():
	var btn := buttons[selected_index]
	var pointer_size = pointer.texture.get_size()

	var btn_pos_in_menu = vbox_container.position + btn.position

	pointer.position = Vector2(
		btn_pos_in_menu.x - pointer_size.x - 6, # shift left of button
		btn_pos_in_menu.y + ((btn.get_size().y - pointer_size.y) / 2) + 8
	)
