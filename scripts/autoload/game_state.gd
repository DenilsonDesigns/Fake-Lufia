extends Node

var player_stats = {
	"level": 1,
	"hp": 100,
	"max_hp": 100,
	"gold": 0,
	"inventory": [],
}

var current_scene_path = "res://scenes/main.tscn"

func save_game():
	pass # serialize to file later

func load_game():
	pass # restore from file later
