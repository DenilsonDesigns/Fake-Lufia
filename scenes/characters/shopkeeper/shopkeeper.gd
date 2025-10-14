extends CharacterBody2D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var tend_target: Marker2D = $TendTarget

var move_speed := 60.0
var moving := false
var start_position := Vector2.ZERO
var target_position := Vector2.ZERO

func _ready():
	start_position = global_position
	target_position = global_position

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

func _on_interaction_area_body_entered(_body: Node2D) -> void:
	# @TODO: for now, this wont do anything
	# if body.name == "Player":
	# 	body.show_interact_prompt("Talk")
	print("entered")
	target_position = tend_target.global_position
	moving = true

func _on_interaction_area_body_exited(_body: Node2D) -> void:
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
	# Called by the player when pressing "interact" inside InteractionArea
	# @TODO: for now, wont be used.
	target_position = tend_target.global_position
	moving = true
