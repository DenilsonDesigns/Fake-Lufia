class_name SelanBattle extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func play_attack():
	anim_player.play("attack")

func play_idle():
	anim_player.play("idle")

func play_dead():
	anim_player.play("dead")

func play_take_hit():
	anim_player.play("take_hit")