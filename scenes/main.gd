extends Node2D

@onready var encounter_zone: Area2D = %EncounterZone

func _ready():
	encounter_zone.add_to_group("encounter_zones")
	for zone in get_tree().get_nodes_in_group("encounter_zones"):
		GameState.register_encounter_zone(zone)
