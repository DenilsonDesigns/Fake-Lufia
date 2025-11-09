extends Node

var current_encounter_zone: Area2D = null
var encounter_timer: Timer

var player_stats = {
	"level": 1,
	"hp": 70,
	"max_hp": 100,
	"gold": 0,
	"inventory": [],
	"mp": 150,
	"max_mp": 200
}

var current_scene_path = "res://scenes/main.tscn"

func save_game():
	pass # serialize to file later

func load_game():
	pass # restore from file later

func _ready() -> void:
	encounter_timer = Timer.new()
	encounter_timer.wait_time = 2.0
	encounter_timer.autostart = false
	encounter_timer.timeout.connect(_on_encounter_roll)
	add_child(encounter_timer)

func register_encounter_zone(zone: Area2D) -> void:
	zone.player_entered_zone.connect(_on_player_entered_zone)
	zone.player_exited_zone.connect(_on_player_exited_zone)

func _on_player_entered_zone(zone: Area2D) -> void:
	current_encounter_zone = zone
	encounter_timer.start()

func _on_player_exited_zone(zone: Area2D) -> void:
	if current_encounter_zone == zone:
		current_encounter_zone = null
		encounter_timer.stop()

func _on_encounter_roll() -> void:
	if current_encounter_zone and randf() < 0.45:
		current_scene_path = get_tree().current_scene.scene_file_path
		LevelSwapper.level_swap_to_battle(current_scene_path, "res://scenes/battle/battle_field.tscn")

func get_player_stats() -> Dictionary:
	return player_stats.duplicate()
