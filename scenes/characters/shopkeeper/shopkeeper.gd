extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tend_target: Marker2D = $TendTarget
@export var interaction_area: Area2D

var move_speed := 60.0
var moving := false
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO

func _ready():
	if interaction_area == null:
		push_error("Shopkeeper missing InteractionArea reference! Please assign it in the Inspector.")
		return
	
	start_position = global_position
	target_position = global_position

	interaction_area.body_entered.connect(_on_interaction_area_body_entered)
	interaction_area.body_exited.connect(_on_interaction_area_body_exited)

func _physics_process(_delta):
	if moving:
		var direction = (target_position - global_position).normalized()
		velocity = direction * move_speed

		_play_walk_animation(direction)
		move_and_slide()

		if global_position.distance_to(target_position) < 2.0:
			moving = false
			velocity = Vector2.ZERO
			_play_idle_animation(direction)

func _on_interaction_area_body_entered(body: Node2D) -> void:
	if body.name == "Selan":
		print("entered")
		target_position = tend_target.global_position
		moving = true

func _on_interaction_area_body_exited(body: Node2D) -> void:
	if body.name == "Selan":
		print("exited")
		target_position = start_position
		moving = true

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

func interact():
	target_position = tend_target.global_position
	moving = true
