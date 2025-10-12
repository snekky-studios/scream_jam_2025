class_name Picture
extends Node2D

signal clue_found
signal final_animation_begun
signal final_animation_ended

const DEBUG : bool = false

const MAGNIFY_RADIUS_SHADER : float = 0.1
const MAGNIFY_RADIUS : float = (MAGNIFY_RADIUS_SHADER * 256.0)

enum State
{
	START,
	SEARCHING_CLUE_INVISIBLE,
	SEARCHING_CLUE_VISIBLE,
	CLUE_SEEN,
	CLUE_FOUND
}

var state : State : set = _set_state
@export var data : PictureData = null : set = _set_data
var magnify_enabled : bool = true
var try_enable_find_clue : bool = false
var find_clue_enabled : bool = false
var has_clue_been_seen : bool = false

var sprite_128 : Sprite2D = null
var sprite_256 : Sprite2D = null
var sub_viewport_container_256 : SubViewportContainer = null
var animation_player_128 : AnimationPlayer = null
var animation_player_256 : AnimationPlayer = null
var animation_player_last_picture : AnimationPlayer = null
var label_start : LabelDelay = null
var label_end : LabelDelay = null
var label_final : LabelDelay = null
var timer_try_find_clue : Timer = null
var timer_last_picture : Timer = null
var audio_stream_player_piano : AudioStreamPlayer = null

func _ready() -> void:
	sprite_128 = %Sprite128
	sprite_256 = %Sprite256
	sub_viewport_container_256 = %SubViewportContainer256
	animation_player_128 = %AnimationPlayer128
	animation_player_256 = %AnimationPlayer256
	animation_player_last_picture = %AnimationPlayerLastPicture
	label_start = %LabelDelayStart
	label_end = %LabelDelayEnd
	label_final = %LabelDelayFinal
	timer_try_find_clue = %TimerTryFindClue
	timer_last_picture = %TimerLastPicture
	audio_stream_player_piano = %AudioStreamPlayerPiano
	
	label_start.completed.connect(func(): timer_try_find_clue.start())
	label_end.completed.connect(_on_label_end_completed)
	label_final.completed.connect(func(): final_animation_ended.emit())
	
	animation_player_128.play("play_128")
	animation_player_256.play("play_256")
	
	timer_try_find_clue.wait_time = randi_range(2, 5)
	return

func _physics_process(_delta : float) -> void:
	if(not data or not magnify_enabled):
		return
	var mouse_position : Vector2 = get_global_mouse_position()
	magnify_set_location(mouse_position.x, mouse_position.y)
	if(try_enable_find_clue):
		if(mouse_position.distance_squared_to(data.clue_coordinates) > MAGNIFY_RADIUS * MAGNIFY_RADIUS):
			swap_256()
	if(not has_clue_been_seen and find_clue_enabled):
		if(mouse_position.distance_squared_to(data.clue_coordinates) < 0.65 * MAGNIFY_RADIUS * MAGNIFY_RADIUS):
			audio_stream_player_piano.play()
			has_clue_been_seen = true
	if(DEBUG):
		print(mouse_position)
	return

func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton and
	event.is_pressed() and
	find_clue_enabled and
	get_global_mouse_position().distance_squared_to(data.clue_coordinates) < (MAGNIFY_RADIUS * MAGNIFY_RADIUS)):
		label_end.text = data.end_text
		if(data.last_picture):
			label_end.start(0.03)
		else:
			label_end.start(0.06)
	return

func _set_state(value : State) -> void:
	state = value
	_on_state_changed()
	return

func _set_data(value : PictureData) -> void:
	data = value
	sprite_128.texture = data.texture_128
	sprite_256.texture = data.texture_256
	label_start.text = data.start_text
	if(not data.last_picture):
		magnify_enable()
		label_start.start(0.03)
	else:
		label_start.start(0.06)
		label_start.is_last_picture = true
		magnify_disable()
		timer_last_picture.start()
	return

func _on_state_changed() -> void:
	match state:
		State.START:
			pass
		State.SEARCHING_CLUE_INVISIBLE:
			pass
		State.SEARCHING_CLUE_VISIBLE:
			pass
		State.CLUE_SEEN:
			pass
		State.CLUE_FOUND:
			pass
		_:
			print("error: invalid state - ", state)
	return

func reset():
	try_enable_find_clue = false
	find_clue_enabled = false
	has_clue_been_seen = false
	label_start.reset()
	label_end.reset()
	magnify_disable()
	return

func swap_256() -> void:
	sprite_256.texture = data.texture_256_delay
	find_clue_enabled = true
	return

func magnify_enable() -> void:
	magnify_enabled = true
	sub_viewport_container_256.show()
	return

func magnify_disable() -> void:
	magnify_enabled = false
	sub_viewport_container_256.hide()
	return

func magnify_set_location(x : float, y : float) -> void:
	var proportion_x : float = (x - sprite_128.position.x) / float(sprite_128.texture.get_width())
	var proportion_y : float = (y - sprite_128.position.y) / (float(sprite_128.texture.get_height()) / float(sprite_128.vframes))
	sub_viewport_container_256.material.set_shader_parameter("x", proportion_x)
	sub_viewport_container_256.material.set_shader_parameter("y", proportion_y)
	sub_viewport_container_256.position.x = sprite_128.position.x - 0.5 * proportion_x * sprite_256.texture.get_width()
	sub_viewport_container_256.position.y = sprite_128.position.y - 0.5 * proportion_y * (sprite_256.texture.get_height() / float(sprite_256.vframes))
	return

func _on_timer_try_find_clue_timeout() -> void:
	try_enable_find_clue = true
	return

func _on_label_end_completed() -> void:
	await get_tree().create_timer(5.0).timeout
	magnify_disable()
	clue_found.emit()
	return

func _on_timer_last_picture_timeout() -> void:
	final_animation_begun.emit()
	label_start.reset()
	label_end.reset()
	animation_player_last_picture.play("flash")
	await animation_player_last_picture.animation_finished
	animation_player_last_picture.play("RESET")
	label_final.show()
	label_final.final()
	return
