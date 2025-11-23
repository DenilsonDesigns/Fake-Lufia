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
@onready var item_menu: PanelContainer = $ItemMenu

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

var BATTLE_THEME = preload("res://assets/audio/battle_theme.ogg")

var state: BattleState = BattleState.IDLE

func _ready():
	await get_tree().process_frame
	AudioManager.crossfade_bgm(BATTLE_THEME, 0.5)

	action_selection_card.action_selected.connect(_on_action_selected)
	pointer.visible = false

	item_menu.item_selected.connect(_on_item_chosen)
	item_menu.item_selection_cancelled.connect(_on_item_menu_cancelled)

	GameState.player_stats_changed.connect(_on_player_stats_changed)

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
	state = BattleState.PLAYER_TURN
	show_player_action_select_menu(true)

func show_player_action_select_menu(show_menu: bool) -> void:
	if (show_menu):
		item_menu.close()

	action_selection_card.visible = show_menu
	set_process(visible)
	await get_tree().process_frame
	action_selection_card.grab_focus()

func start_player_turn():
	state = BattleState.PLAYER_TURN
	
	item_menu.close()
	show_player_action_select_menu(true)
	
	action_selection_card.selected_index = 0
	action_selection_card._update_icon_selection()

func start_enemy_turn():
	state = BattleState.ENEMY_TURN
	await get_tree().create_timer(1.0).timeout
	resolve_enemy_action()

func resolve_player_action(action: String):
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

func resolve_enemy_action():
	var enemies = enemy_container.get_children()
	for enemy in enemies:
		await _perform_enemy_attack(enemy)

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

		if enemy is EnemyBase:
			enemy.died.connect(_on_enemy_died)

func _on_enemy_died():
	await get_tree().process_frame
	var enemies = enemy_container.get_children()
	if enemies.is_empty():
		battle_win()

func battle_win():
	state = BattleState.VICTORY

	pointer.visible = false
	show_player_action_select_menu(false)

	await get_tree().create_timer(1.0).timeout

	# End battle and return to overworld
	LevelSwapper.return_from_battle()

func _on_action_selected(action: String) -> void:
	show_player_action_select_menu(false)

	if action == "attack":
		start_target_selection()
	elif action == "item":
		show_item_menu()
	else:
		resolve_player_action(action)

func start_target_selection() -> void:
	action_selection_card.grab_focus()
	state = BattleState.TARGET_SELECTION
	selecting_target = true
	selected_enemy_index = 0

	var enemies = enemy_container.get_children()
	if enemies.is_empty():
		push_error("No enemies to target!")
		return

	update_pointer_position()
	pointer.visible = true

func show_item_menu():
	state = BattleState.PLAYER_TURN

	var potion_amount: int = GameState.inventory.get("potion", 0)
	item_menu.open(potion_amount)

func _on_item_chosen(item_name: String) -> void:
	match item_name:
		"potion":
			if GameState.inventory.get("potion", 0) <= 0:
				print("No potions left!")
				show_player_action_select_menu(true)
				return
			use_potion()


func _on_item_menu_cancelled() -> void:
	show_player_action_select_menu(true)

func use_potion():
	var inventory = GameState.inventory
	
	inventory["potion"] -= 1

	var heal_amount = 50
	GameState.heal_player(heal_amount)

	print("Used potion, healed ", heal_amount)
	item_menu.close()
	end_player_turn()

func update_pointer_position():
	var enemies = enemy_container.get_children()
	if enemies.is_empty():
		return

	var enemy = enemies[selected_enemy_index]
	var target_pos = enemy.global_position + Vector2(-16, -10) # tweak to look good

	var tween = create_tween()
	tween.tween_property(pointer, "global_position", target_pos, 0.1)

func _perform_enemy_attack(enemy: Node) -> void:
	if enemy is EnemyBase:
		enemy.play_attack()
		await enemy.anim_player.animation_finished
		selan_battle.play_take_hit()
		await selan_battle.anim_player.animation_finished

	GameState.damage_player(enemy.attack_power)

	if GameState.get_player_stats()["hp"] <= 0:
		await battle_lose()
		return
	
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
	selan_battle.play_attack()
	await selan_battle.get_node("AnimationPlayer").animation_finished
	selan_battle.play_idle()

	if target is EnemyBase:
		target.play_take_hit()
		await target.anim_player.animation_finished

	target.take_damage(GameState.get_player_stats()["attack_strength"])
	end_player_turn()

func _on_player_stats_changed(new_stats: Dictionary) -> void:
	hp_bar.setup(new_stats["hp"], new_stats["max_hp"])
	mp_bar.setup(new_stats["mp"], new_stats["max_mp"])

func battle_lose() -> void:
	state = BattleState.DEFEAT

	show_player_action_select_menu(false)
	pointer.visible = false

	await get_tree().create_timer(1.0).timeout

	LevelSwapper.return_from_battle()
