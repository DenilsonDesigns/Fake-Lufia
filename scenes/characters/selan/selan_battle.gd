class_name SelanBattle extends Node2D

@onready var anim: AnimationPlayer = $AnimationPlayer

func play_attack():
	anim.play("attack")

func play_idle():
	anim.play("idle")

func play_dead():
	anim.play("dead")