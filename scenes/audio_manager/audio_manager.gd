class_name AudioManager
extends Node

var audio_stream_player_music : AudioStreamPlayer = null
var audio_stream_player_violins_plucking : AudioStreamPlayer = null
var audio_stream_player_violins_screeching : AudioStreamPlayer = null
var audio_stream_player_piano : AudioStreamPlayer = null
var audio_stream_player_pluck : AudioStreamPlayer = null
var audio_stream_player_string : AudioStreamPlayer = null

func _ready() -> void:
	audio_stream_player_music = %AudioStreamPlayerMusic
	audio_stream_player_violins_plucking = %AudioStreamPlayerViolinsPlucking
	audio_stream_player_violins_screeching = %AudioStreamPlayerViolinsScreeching
	audio_stream_player_piano = %AudioStreamPlayerPiano
	audio_stream_player_pluck = %AudioStreamPlayerPluck
	audio_stream_player_string = %AudioStreamPlayerString
	return

func play(track : String) -> void:
	match track:
		"MUSIC":
			audio_stream_player_music.play()
		"VIOLINS_PLUCKING":
			audio_stream_player_violins_plucking.play()
		"VIOLINS_SCREECHING":
			audio_stream_player_violins_screeching.play()
		"PIANO":
			audio_stream_player_piano.play()
		"PLUCK":
			audio_stream_player_pluck.play()
		"STRING":
			audio_stream_player_string.play()
		_:
			print("error: invalid audio track ", track)
	return

func stop(track : String) -> void:
	match track:
		"MUSIC":
			audio_stream_player_music.stop()
		"VIOLINS_PLUCKING":
			audio_stream_player_violins_plucking.stop()
		"VIOLINS_SCREECHING":
			audio_stream_player_violins_screeching.stop()
		"PIANO":
			audio_stream_player_piano.stop()
		"PLUCK":
			audio_stream_player_pluck.stop()
		"STRING":
			audio_stream_player_string.stop()
		_:
			print("error: invalid audio track ", track)
	return

func stop_all() -> void:
	audio_stream_player_music.stop()
	audio_stream_player_violins_plucking.stop()
	audio_stream_player_violins_screeching.stop()
	audio_stream_player_piano.stop()
	audio_stream_player_pluck.stop()
	audio_stream_player_string.stop()
	return

func fade_out(track : String, time : float) -> void:
	var tween : Tween = get_tree().create_tween()
	match track:
		"MUSIC":
			tween.tween_property(audio_stream_player_music, "volume_linear", 0, time)
		"VIOLINS_PLUCKING":
			tween.tween_property(audio_stream_player_violins_plucking, "volume_linear", 0, time)
		"VIOLINS_SCREECHING":
			tween.tween_property(audio_stream_player_violins_screeching, "volume_linear", 0, time)
		"PIANO":
			tween.tween_property(audio_stream_player_piano, "volume_linear", 0, time)
		"PLUCK":
			tween.tween_property(audio_stream_player_pluck, "volume_linear", 0, time)
		"STRING":
			tween.tween_property(audio_stream_player_string, "volume_linear", 0, time)
		_:
			print("error: invalid audio track ", track)
	return
