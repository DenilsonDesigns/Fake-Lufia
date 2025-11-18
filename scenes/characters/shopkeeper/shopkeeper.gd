class_name Shopkeeper extends NPC

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var shop_menu: PanelContainer = $ShopMenu

@export var tend_target: Marker2D
@export var shop_milling: Array[Marker2D] = []
@export var interaction_area: Area2D

@export var conversation: ConversationResource
@export var display_name: String = "Shopkeeper"

var move_speed := 40.0
var moving := false
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO
var target_is_tend := false
var wander_timer := 0.0
var wander_delay := 3.0
var current_spot: Vector2 = Vector2.ZERO
var last_direction: Vector2 = Vector2.DOWN

func _ready():
	randomize()
	shop_menu.visible = false

	if interaction_area == null:
		push_error("Shopkeeper missing InteractionArea reference! Please assign it in the Inspector.")
		return

	if tend_target == null:
		push_error("Shopkeeper missing tend_target! Please assign it in the Inspector.")

	if shop_milling.size() == 0:
		push_warning("Shopkeeper shop_milling array is empty. She won't wander.")
	else:
		for i in range(shop_milling.size()):
			if shop_milling[i] == null:
				push_warning("Shopkeeper shop_milling contains a null entry at index %d." % i)

	start_position = global_position
	target_position = global_position

	DialogueManager.conversation_finished.connect(_on_conversation_finished)

	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)
	interaction_area.area_entered.connect(_on_interaction_area_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_area_exited)

func _physics_process(delta):
	if moving:
		var direction = (target_position - global_position).normalized()
		velocity = direction * move_speed
		last_direction = direction

		_play_walk_animation(direction)
		move_and_slide()

		if global_position.distance_to(target_position) < 2.0:
			global_position = target_position
			moving = false
			velocity = Vector2.ZERO

			if target_is_tend:
				animation_player.play("idle_down")
			elif shop_milling.size() > 0 and target_position in _shop_milling_positions():
				animation_player.play("idle_up")
			else:
				_play_idle_animation(last_direction)
	else:
		if not target_is_tend and shop_milling.size() > 0:
			wander_timer += delta
			if wander_timer >= wander_delay:
				_pick_new_milling_target()
				wander_timer = 0.0

func _on_conversation_finished(actor):
	if actor == self:
		show_shop()

func show_shop():
	shop_menu.visible = true
	shop_menu.grab_focus()

func _pick_new_milling_target():
	if shop_milling.size() == 0:
		return
	var idx = randi() % shop_milling.size()
	current_spot = shop_milling[idx].global_position
	target_position = current_spot
	moving = true
	wander_delay = randf_range(2.0, 5.0)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		if tend_target:
			target_position = tend_target.global_position
			target_is_tend = true
			moving = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target_position = start_position
		target_is_tend = false
		moving = true

func _on_interaction_area_area_entered(area: Area2D) -> void:
	if area.is_in_group("player_interact_detector"):
		area.owner.interact_target = self

func _on_interaction_area_area_exited(area: Area2D) -> void:
	if area.is_in_group("player_interact_detector"):
		if area.owner.interact_target == self:
			area.owner.interact_target = null

func _play_walk_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		animation_player.play("walk_right" if direction.x > 0 else "walk_left")
	else:
		animation_player.play("walk_down" if direction.y > 0 else "walk_up")

func _play_idle_animation(direction: Vector2):
	if abs(direction.x) > abs(direction.y):
		animation_player.play("idle_right" if direction.x > 0 else "idle_left")
	else:
		animation_player.play("idle_down" if direction.y > 0 else "idle_up")

# NEW — used by the dialogue system to display the name
func get_display_name() -> String:
	return display_name

# -------------------------------------------------
# NEW Dialogue System Implementation
# -------------------------------------------------
func interact():
	# Player triggered this NPC — start the conversation
	if conversation:
		DialogueManager.start(
			conversation,
			{
				"npc": self,
				"player": get_tree().get_first_node_in_group("player")
			}
		)

func _shop_milling_positions() -> Array:
	var positions := []
	for m in shop_milling:
		positions.append(m.global_position)
	return positions
