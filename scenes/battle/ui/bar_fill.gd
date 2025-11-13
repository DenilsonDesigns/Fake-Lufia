extends AnimatedSprite2D

@export_enum("HP", "MP") var bar_type: String = "HP"
@export var hp_texture: Texture2D
@export var mp_texture: Texture2D

var ratio: float = 1.0:
	set(value):
		ratio = clamp(value, 0.0, 1.0)
		_update_fill()

var original_position: Vector2

func _ready():
	if hp_texture == null:
		hp_texture = load("res://assets/battle/hp_bar_fill.png")
	if mp_texture == null:
		mp_texture = load("res://assets/battle/mp_bar_fill.png")

	var tex = hp_texture if bar_type == "HP" else mp_texture
	var sf = SpriteFrames.new()
	sf.add_animation("default")
	sf.add_frame("default", tex)
	sprite_frames = sf
	animation = "default"
	play()

	original_position = position
	_update_fill()

func setup(current: float, max_value: float) -> void:
	var new_ratio = 0.0 if max_value <= 0.0 else current / max_value
	set_ratio_animated(new_ratio)

func _update_fill():
	visible = ratio > 0.0
	scale.x = ratio
	var tex_width = hp_texture.get_size().x if bar_type == "HP" else mp_texture.get_size().x
	position.x = original_position.x - (1.0 - ratio) * tex_width * 0.5

func set_ratio_animated(target: float, duration := 0.2):
	target = clamp(target, 0.0, 1.0)
	var tween = create_tween()
	tween.tween_property(self, "ratio", target, duration)
