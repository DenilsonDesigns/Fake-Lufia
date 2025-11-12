extends Node2D

@export_file("*.png") var background_texture_path: String
@export var enemy_scenes: Array[PackedScene] = []
@onready var enemy_container := $EnemyContainer
@onready var selan_battle: SelanBattle = $SelanBattle
@onready var player_stats_card := $PlayerStatsCard
@onready var action_selection_card := $ActionSelectionCard
@onready var hp_bar := $PlayerStatsCard/HPBar/BarFill
@onready var mp_bar := $PlayerStatsCard/MPBar/BarFill
@onready var pointer: Sprite2D = $Pointer

var selected_enemy_index := 0
var selecting_target := false

const MIN_X: float = -90.0
const MAX_X: float = 90.0
const MIN_Y: float = -65.0
const MAX_Y: float = -40.0

enum BattleState {
	IDLE,
	PLAYER_TURN,
	TARGET_SELECTION,
	ENEMY_TURN,
	RESOLVING,
	VICTORY,
	DEFEAT
}

var state: BattleState = BattleState.IDLE

func _ready():
	action_selection_card.action_selected.connect(_on_action_selected)

	pointer.visible = false

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

func start_player_turn():
	state = BattleState.PLAYER_TURN
	
	# Show the action selection card/UI
	show_player_action_select_menu(true)
	
	# Optionally highlight the first action
	action_selection_card.selected_index = 0
	action_selection_card._update_icon_selection()
	
	print("Player's turn!")

func on_player_action_selected(action: String) -> void:
	state = BattleState.RESOLVING
	show_player_action_select_menu(false)
	# @TODO: create method:
	resolve_player_action(action)

func start_enemy_turn():
	state = BattleState.ENEMY_TURN
	print("Enemy is thinking...")
	await get_tree().create_timer(1.0).timeout # fake delay
	# @TODO: create method:
	resolve_enemy_action()

func resolve_player_action(action: String):
	print("Player used %s!" % action)
	# TODO: Apply damage/heal/etc.
	match action:
		"attack":
			selan_battle.play_attack()
			await selan_battle.get_node("AnimationPlayer").animation_finished
			selan_battle.play_idle()
			end_player_turn()
		"defend":
			print("Defending...")
			end_player_turn()
		"item":
			print("Using item...")
			end_player_turn()
	# @TODO: create method:
	# check_battle_end()

func resolve_enemy_action():
	var enemies = enemy_container.get_children()
	for enemy in enemies:
		await _perform_enemy_attack(enemy)

	# After all enemies acted, hand turn back to player
	# @TODO: create:
	start_player_turn()

func end_player_turn():
	state = BattleState.ENEMY_TURN
	show_player_action_select_menu(false)
	start_enemy_turn()

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

func _on_action_selected(action: String) -> void:
	print("Player chose action: ", action)
	show_player_action_select_menu(false)

	if action == "attack":
		start_target_selection()
	else:
		resolve_player_action(action)

func start_target_selection() -> void:
	state = BattleState.TARGET_SELECTION
	selecting_target = true
	selected_enemy_index = 0

	var enemies = enemy_container.get_children()
	if enemies.is_empty():
		push_error("No enemies to target!")
		return

	# Position pointer near first enemy
	update_pointer_position()
	pointer.visible = true
	print("Selecting target...")

func update_pointer_position():
	var enemies = enemy_container.get_children()
	if enemies.is_empty():
		return

	var enemy = enemies[selected_enemy_index]
	var target_pos = enemy.global_position + Vector2(-16, -10) # tweak to look good

	var tween = create_tween()
	tween.tween_property(pointer, "global_position", target_pos, 0.1)

func _perform_enemy_attack(enemy: Node) -> void:
	print("%s is attacking!" % enemy.name)

	if enemy is EnemyBase:
		enemy.play_attack()
		await enemy.anim_player.animation_finished
		selan_battle.play_take_hit()
		await selan_battle.anim_player.animation_finished

	# Apply damage (simple example)
	var damage = 5 # Or randomize
	# @TODO: make this method:
	# GameState.damage_player(damage)
	print("Player took %d damage!" % damage)
	
	# Small delay after attack
	await get_tree().create_timer(0.5).timeout

func _unhandled_input(event: InputEvent) -> void:
	# @TODO: refactor to have handlers based on BattleState
	if event.is_action_pressed("ui_cancel"):
		if state == BattleState.TARGET_SELECTION:
			print("Canceled targeting.")
			selecting_target = false
			pointer.visible = false
			state = BattleState.PLAYER_TURN
			show_player_action_select_menu(true)
			return
		print("Exiting battle, returning to field...")
		LevelSwapper.return_from_battle()

	elif state == BattleState.TARGET_SELECTION:
		var enemies = enemy_container.get_children()

		if event.is_action_pressed("ui_right"):
			selected_enemy_index = (selected_enemy_index + 1) % enemies.size()
			update_pointer_position()

		elif event.is_action_pressed("ui_left"):
			selected_enemy_index = (selected_enemy_index - 1 + enemies.size()) % enemies.size()
			update_pointer_position()

		elif event.is_action_pressed("ui_accept"):
			var target = enemies[selected_enemy_index]
			print("Confirmed target: ", target.name)
			selecting_target = false
			pointer.visible = false
			resolve_attack_target(target)

func resolve_attack_target(target: Node):
	state = BattleState.RESOLVING
	print("Attacking target: ", target.name)
	selan_battle.play_attack()
	await selan_battle.get_node("AnimationPlayer").animation_finished
	selan_battle.play_idle()

	if target is EnemyBase:
		target.play_take_hit()
		await target.anim_player.animation_finished

	# TODO: Apply damage to target here
	print("%s took damage!" % target.name)
	# @TODO: enemy to play take_hit anim
	# target.play_animation("take_hit")

	end_player_turn()