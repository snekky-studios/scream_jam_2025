class_name LabelNarration
extends Label

var index_char_current : int = 0
var index_char_target : int = 0
var character_delay_time : float = 0.03
var timer : float = 0.0

func _ready() -> void:
	visible_characters = index_char_current
	return

func _physics_process(delta: float) -> void:
	timer += delta
	if(timer > character_delay_time):
		timer = 0.0
		if(index_char_current < index_char_target):
			index_char_current += 1
			visible_characters = index_char_current
	return
