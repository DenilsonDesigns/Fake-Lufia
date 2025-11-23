extends Node2D

@onready var bgm_player: AudioStreamPlayer = $BGMPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer
@onready var sfx_pool: Node = $SFXPool

# ==========================================================
# BGM Control
# ==========================================================
func play_bgm(stream: AudioStream, volume_db := 0.0, fade_in := 0.0):
	if fade_in > 0:
		bgm_player.volume_db = -80
		bgm_player.stream = stream
		bgm_player.play()
		_start_fade(bgm_player, volume_db, fade_in)
	else:
		bgm_player.stream = stream
		bgm_player.volume_db = volume_db
		bgm_player.play()

func stop_bgm(fade_out := 0.0):
	if fade_out > 0:
		_start_fade(bgm_player, -80, fade_out).tween_callback(bgm_player.stop)
	else:
		bgm_player.stop()

func crossfade_bgm(new_stream: AudioStream, duration := 1.0, target_db := 0.0):
	# create temp fading-out player
	var temp_player := AudioStreamPlayer.new()
	temp_player.stream = bgm_player.stream
	temp_player.volume_db = bgm_player.volume_db
	temp_player.bus = bgm_player.bus
	add_child(temp_player)
	temp_player.play()

	# start new stream
	bgm_player.stream = new_stream
	bgm_player.volume_db = -80
	bgm_player.play()

	# fade them
	_start_fade(bgm_player, target_db, duration)
	_start_fade(temp_player, -80, duration).tween_callback(temp_player.queue_free)

# ==========================================================
# SFX
# ==========================================================
func play_sfx(stream: AudioStream, volume_db := 0.0):
	sfx_player.stream = stream
	sfx_player.volume_db = volume_db
	sfx_player.play()

func play_sfx_overlapping(stream: AudioStream, volume_db := 0.0):
	for player in sfx_pool.get_children():
		if not player.playing:
			player.stream = stream
			player.volume_db = volume_db
			player.play()
			return

	var p = sfx_pool.get_child(0)
	p.stream = stream
	p.volume_db = volume_db
	p.play()

# ==========================================================
# Fade Helper
# ==========================================================
func _start_fade(player, target_db: float, duration: float) -> Tween:
	var t := create_tween().set_parallel()
	t.tween_property(player, "volume_db", target_db, duration)
	return t
