class_name Selan extends CharacterBody2D

@export var speed: float = 100.0

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var last_direction := Vector2.DOWN

func _physics_process(_delta: float) -> void:
	var direction := _get_direction_from_input()

	if direction != Vector2.ZERO:
		velocity = direction * speed
		last_direction = direction
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	if direction == Vector2.ZERO:
		_handle_animation("idle", last_direction)
	else:
		_handle_animation("walk", direction)

func _play_animation(animation_name: String) -> void:
	if anim_player.current_animation != animation_name:
		anim_player.play(animation_name)

func _handle_animation(anim_type: String, anim_direction: Vector2) -> void:
	var dir_string = DirectionUtils.vector2_to_direction(anim_direction)
	_play_animation(anim_type + "_" + dir_string)

func _get_direction_from_input() -> Vector2:
	var out_direction := Vector2.ZERO

	if Input.is_action_pressed("ui_right"):
		out_direction = Vector2.RIGHT
	elif Input.is_action_pressed("ui_left"):
		out_direction = Vector2.LEFT
	elif Input.is_action_pressed("ui_down"):
		out_direction = Vector2.DOWN
	elif Input.is_action_pressed("ui_up"):
		out_direction = Vector2.UP

	return out_direction
