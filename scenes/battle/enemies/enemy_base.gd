class_name EnemyBase extends Node2D

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var attack_power := 3
var hp := 30

func play_attack():
	if anim_player.has_animation("attack"):
		anim_player.play("attack")

func play_take_hit():
	if anim_player.has_animation("take_hit"):
		anim_player.play("take_hit")

func play_idle():
	if anim_player.has_animation("idle"):
		anim_player.play("idle")

# @NOTE: this animation doesn't exist and i can't be bothered making it lol
# it still looks ok with the damage anim then queue_free()
func play_death():
	if anim_player.has_animation("death"):
		anim_player.play("death")

func take_damage(damage: int) -> void:
	hp -= damage
	play_take_hit()

	print("hp after damage", hp)

	if hp <= 0:
		handle_death()

func handle_death():
	play_death()

	set_process(false)
	set_physics_process(false)

	if anim_player.has_animation("death"):
		anim_player.animation_finished.connect(_on_death_animation_finished)
	else:
		queue_free()

func _on_death_animation_finished(anim_name: String):
	if anim_name == "death":
		queue_free()
