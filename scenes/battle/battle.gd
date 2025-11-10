extends Node2D

@export_file("*.png") var background_texture_path: String
@export var enemy_scenes: Array[PackedScene] = []
@onready var enemy_container := $EnemyContainer
@onready var player_stats_card := $PlayerStatsCard
@onready var action_selection_card := $ActionSelectionCard
@onready var hp_bar := $PlayerStatsCard/HPBar/BarFill
@onready var mp_bar := $PlayerStatsCard/MPBar/BarFill

const MIN_X: float = -90.0
const MAX_X: float = 90.0
const MIN_Y: float = -65.0
const MAX_Y: float = -40.0

enum BattleState {
	IDLE,
	PLAYER_TURN,
	ENEMY_TURN,
	RESOLVING,
	VICTORY,
	DEFEAT
}

var state: BattleState = BattleState.IDLE

func _ready():
	action_selection_card.action_selected.connect(_on_action_selected)

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
	
	start_battle()


func start_battle():
	print("Battle started!")
	state = BattleState.PLAYER_TURN
	show_player_action_select_menu(true)

func show_player_action_select_menu(show_menu: bool) -> void:
	action_selection_card.visible = show_menu
	set_process(visible)

func on_player_action_selected(action: String) -> void:
	state = BattleState.RESOLVING
	show_player_action_select_menu(false)
	# @TODO: create method:
	# resolve_player_action(action)

func start_enemy_turn():
	state = BattleState.ENEMY_TURN
	print("Enemy is thinking...")
	await get_tree().create_timer(1.0).timeout # fake delay
	# @TODO: create method:
	# resolve_enemy_action()

func resolve_player_action(action: String):
	print("Player used %s!" % action)
	# TODO: Apply damage/heal/etc.
	# @TODO: create method:
	# check_battle_end()

func resolve_enemy_action():
	print("Enemy attacks!")
	# TODO: Apply damage
	# @TODO: create method:
	# check_battle_end()

func check_battle_end():
	if GameState.get_player_stats()["hp"] <= 0:
		state = BattleState.DEFEAT
		print("You lose!")
	# @TODO: create method:
	# elif enemies_defeated():
	# 	state = BattleState.VICTORY
	# 	print("You win!")
	else:
		state = BattleState.PLAYER_TURN
		# @TODO: create method:
		show_player_action_select_menu(true)

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

func _on_action_selected(action: String) -> void:
	print("Player chose action: ", action)
	show_player_action_select_menu(false)
	resolve_player_action(action)
