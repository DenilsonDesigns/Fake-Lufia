extends Node2D

@onready var encounter_zone: Area2D = %EncounterZone

var BGM_OVERWORLD = preload("res://assets/audio/town_theme.mp3")

func _ready():
	encounter_zone.add_to_group("encounter_zones")
	for zone in get_tree().get_nodes_in_group("encounter_zones"):
		GameState.register_encounter_zone(zone)

	AudioManager.play_bgm(BGM_OVERWORLD)
