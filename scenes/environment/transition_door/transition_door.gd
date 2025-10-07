class_name TransitionDoor extends Area2D

@export_file("*.tscn") var new_area: String
@export_range(0, 32) var connection: int
@export var door_sound_effect: bool = false

@onready var drop_point = $DropPoint