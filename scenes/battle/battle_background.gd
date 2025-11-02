extends Node2D

@export var background_texture: Texture2D

func _ready():
	if background_texture == null:
		push_error("❌ BattleBackground: No background texture assigned!")
		assert(false, "BattleBackground requires a background_texture to be set.")
		return
	
	var sprite = $Sprite2D
	sprite.texture = background_texture
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
