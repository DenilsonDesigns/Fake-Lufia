class_name EnemyBase extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func play_attack():
	if anim_player.has_animation("attack"):
		anim_player.play("attack")

func play_take_hit():
	if anim_player.has_animation("take_hit"):
		anim_player.play("take_hit")

func play_idle():
	if anim_player.has_animation("idle"):
		anim_player.play("idle")
