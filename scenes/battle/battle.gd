extends Node2D

@export_file("*.png") var background_texture_path: String
@export var enemy_scenes: Array[PackedScene] = []
@onready var enemy_container := $EnemyContainer
@onready var player_stats_card := $PlayerStatsCard
@onready var hp_bar := $PlayerStatsCard/HPBar/BarFill
@onready var mp_bar := $PlayerStatsCard/MPBar/BarFill

const MIN_X: float = -90.0
const MAX_X: float = 90.0
const MIN_Y: float = -65.0
const MAX_Y: float = -40.0

func _ready():
	if background_texture_path == "":
		push_error("Battle background not set!")
		return

	var bg_texture: Texture2D = load(background_texture_path)
	if bg_texture == null:
		push_error("Failed to load battle background: %s" % background_texture_path)
		return

	if enemy_scenes.is_empty():
		push_error("No enemies assigned to battle scene!")
		return

	_spawn_enemies()

func setup(player_stats: Dictionary) -> void:
	if hp_bar:
		hp_bar.setup(player_stats["hp"], player_stats["max_hp"])
	if mp_bar:
		mp_bar.setup(player_stats["mp"], player_stats["max_mp"])


func _spawn_enemies():
	var count: int = enemy_scenes.size()

	for i in range(count):
		var enemy_scene: PackedScene = enemy_scenes[i]
		var enemy := enemy_scene.instantiate()

		var t: float = 0.0 if count == 1 else float(i) / float(count - 1)
		var x: float = lerp(MIN_X, MAX_X, t)

		var y: float = randf_range(MIN_Y, MAX_Y)

		enemy.position = Vector2(x, y)
		enemy_container.add_child(enemy)

# @NOTE:
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"): # ESC key by default
		print("Exiting battle, returning to field...")
		LevelSwapper.return_from_battle()
