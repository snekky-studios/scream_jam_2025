class_name LabelDelay
extends Label

signal target_reached

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

func snap_in():
	self.modulate = Color(1.0, 1.0, 1.0, 1.0)
	return

func fade_in(time : float):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), time)
	await tween.finished
	return

func fade_out(time : float):
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 0.0), time)
	await tween.finished
	return
