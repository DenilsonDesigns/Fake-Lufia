extends AnimatedSprite2D

@export_enum("HP", "MP") var bar_type: String = "HP"

@export var hp_texture: Texture2D
@export var mp_texture: Texture2D

@export_range(0.0, 1.0, 0.01) var ratio: float = 1.0:
	set(value):
		ratio = clamp(value, 0.0, 1.0)
		_update_frame()

func _ready():
	if hp_texture == null:
		hp_texture = load("res://assets/battle/hp_bar_fill.png")
	if mp_texture == null:
		mp_texture = load("res://assets/battle/mp_bar_fill.png")

	_load_frames()
	_update_frame()

func _load_frames():
	var tex: Texture2D = hp_texture if bar_type == "HP" else mp_texture
	if tex == null:
		push_error("Bar.gd: texture is null for bar_type: %s" % bar_type)
		return

	var sf := SpriteFrames.new()
	var anim_name := "default"

	if not sf.has_animation(anim_name):
		sf.add_animation(anim_name)
	
	sf.set_animation_speed(anim_name, 0)
	sf.set_animation_loop(anim_name, false)

	var tex_size := tex.get_size()
	var frame_w := tex_size.x / 2.0
	var frame_h := tex_size.y

	for i in range(2):
		var at := AtlasTexture.new()
		at.atlas = tex
		at.region = Rect2(i * frame_w, 0, frame_w, frame_h)
		sf.add_frame(anim_name, at)

	sprite_frames = sf
	animation = anim_name
	play(animation)

func _update_frame():
	if ratio <= 0.0:
		visible = false
	else:
		visible = true
		frame = 0 if ratio < 1.0 else 1

func set_ratio_animated(target: float, duration := 0.18):
	target = clamp(target, 0.0, 1.0)
	var tween = create_tween()
	tween.tween_property(self, "ratio", target, duration)
