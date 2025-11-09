extends Area2D

signal player_entered_zone(zone: Area2D)
signal player_exited_zone(zone: Area2D)

func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	connect("body_exited", Callable(self, "_on_body_exited"))

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Selan":
		player_entered_zone.emit(self)

func _on_body_exited(body: Node2D) -> void:
	if body.name == "Selan":
		player_exited_zone.emit(self)
