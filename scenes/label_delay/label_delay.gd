class_name LabelDelay
extends Label

signal target_reached
#signal completed
#
#var audio_stream_player_piano : AudioStreamPlayer = null
#
#var is_completed : bool = false
#var is_started : bool = false
#var is_last_picture : bool = false
#var character_delay_time : float = 0.03
#var normal_character_delay_time : float = 0.0
#var timer : float = 0.0


var index_char_current : int = 0 : set = _set_index_char_current
var index_char_target : int = 0
var character_delay_time : float = 0.03
var timer : float = 0.0

func _ready() -> void:
	index_char_current = 0
	return

func _physics_process(delta: float) -> void:
	timer += delta
	if(timer > character_delay_time):
		timer = 0.0
		if(index_char_current < index_char_target):
			index_char_current += 1
			if(index_char_current == index_char_target):
				target_reached.emit()
	return

func _set_index_char_current(value : int) -> void:
	index_char_current = value
	visible_characters = index_char_current
	return

func reset() -> void:
	index_char_current = 0
	index_char_target = 0
	text = ""
	return

#func _ready() -> void:
	#audio_stream_player_piano = %AudioStreamPlayerPiano
	#visible_characters = 0
	#return
#
#func _physics_process(delta: float) -> void:
	#if(is_completed or not is_started):
		#return
	#timer += delta
	#if(timer > character_delay_time):
		#timer = 0
		#visible_characters += 1
		#if(is_last_picture and (visible_characters == 18 or visible_characters == 24 or visible_characters == 38)):
			#character_delay_time = 0.5
		#else:
			#character_delay_time = normal_character_delay_time
		#if(visible_characters > text.length()):
			#completed.emit()
			#visible_characters = -1
			#is_completed = true
	#return

#func reset():
	#is_completed = false
	#is_started = false
	#is_last_picture = false
	#timer = 0.0
	#visible_characters = 0
	#text = ""
	#return
#
#func start(_character_delay_time : float):
	#character_delay_time = _character_delay_time
	#normal_character_delay_time = _character_delay_time
	#is_started = true
	#return
#
#func final():
	#visible_characters = 3
	#audio_stream_player_piano.play()
	#await get_tree().create_timer(1.0).timeout
	#visible_characters = 7
	#audio_stream_player_piano.play()
	#await get_tree().create_timer(1.0).timeout
	#visible_characters = -1
	#audio_stream_player_piano.play()
	#await get_tree().create_timer(5.0).timeout
	#completed.emit()
	#return
