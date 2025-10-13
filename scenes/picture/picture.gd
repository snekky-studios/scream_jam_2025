class_name Picture
extends Node2D

signal waiting_to_spawn
signal searching_clue_invisible
signal searching_clue_visible
signal clue_seen
signal clue_found
signal final_animation_begun
signal final_animation_ended

const DEBUG : bool = false

const MAGNIFY_RADIUS_SHADER : float = 0.1
const MAGNIFY_RADIUS : float = (MAGNIFY_RADIUS_SHADER * 256.0)

enum State
{
	START,
	WAITING_TO_SPAWN,
	SEARCHING_CLUE_INVISIBLE,
	SEARCHING_CLUE_VISIBLE,
	CLUE_SEEN,
	CLUE_FOUND,
	FINAL_PICTURE
}

var state : State : set = _set_state
@export var data : PictureData = null : set = _set_data

var sprite_128 : Sprite2D = null
var sprite_256 : Sprite2D = null
var sub_viewport_container_256 : SubViewportContainer = null
var animation_player_128 : AnimationPlayer = null
var animation_player_256 : AnimationPlayer = null
var animation_player_last_picture : AnimationPlayer = null
var timer_try_find_clue : Timer = null
var timer_last_picture : Timer = null

func _ready() -> void:
	sprite_128 = %Sprite128
	sprite_256 = %Sprite256
	sub_viewport_container_256 = %SubViewportContainer256
	animation_player_128 = %AnimationPlayer128
	animation_player_256 = %AnimationPlayer256
	animation_player_last_picture = %AnimationPlayerLastPicture
	timer_try_find_clue = %TimerTryFindClue
	timer_last_picture = %TimerLastPicture
	
	animation_player_128.play("play_128")
	animation_player_256.play("play_256")
	
	timer_try_find_clue.wait_time = randi_range(4, 10)
	return

func _physics_process(_delta : float) -> void:
	if(state == State.START or state == State.FINAL_PICTURE):
		return
	
	var mouse_position : Vector2 = get_global_mouse_position()
	magnify_set_location(mouse_position.x, mouse_position.y)
	
	if(state == State.SEARCHING_CLUE_INVISIBLE):
		if(mouse_position.distance_squared_to(data.clue_coordinates) > (2 * MAGNIFY_RADIUS * MAGNIFY_RADIUS)):
			state = State.SEARCHING_CLUE_VISIBLE
	elif(state == State.SEARCHING_CLUE_VISIBLE):
		if(mouse_position.distance_squared_to(data.clue_coordinates) < 0.65 * MAGNIFY_RADIUS * MAGNIFY_RADIUS):
			state = State.CLUE_SEEN
	
	if(DEBUG):
		print(mouse_position)
	return

func _unhandled_input(event: InputEvent) -> void:
	if(event is InputEventMouseButton and
			event.is_pressed() and
			state == State.CLUE_SEEN and
			get_global_mouse_position().distance_squared_to(data.clue_coordinates) < (MAGNIFY_RADIUS * MAGNIFY_RADIUS)):
		state = State.CLUE_FOUND
	return

func _set_state(value : State) -> void:
	state = value
	_on_state_changed()
	return

func _set_data(value : PictureData) -> void:
	data = value
	sprite_128.texture = data.texture_128
	sprite_256.texture = data.texture_256
	if(not data.last_picture):
		state = State.WAITING_TO_SPAWN
	else:
		state = State.FINAL_PICTURE
	return

func _on_state_changed() -> void:
	match state:
		State.START:
			magnify_disable()
		State.WAITING_TO_SPAWN:
			magnify_enable()
			timer_try_find_clue.start()
			waiting_to_spawn.emit()
		State.SEARCHING_CLUE_INVISIBLE:
			searching_clue_invisible.emit()
		State.SEARCHING_CLUE_VISIBLE:
			swap_256()
			searching_clue_visible.emit()
		State.CLUE_SEEN:
			clue_seen.emit()
		State.CLUE_FOUND:
			clue_found.emit()
		State.FINAL_PICTURE:
			magnify_disable()
			timer_last_picture.start()
		_:
			print("error: invalid state - ", state)
	return

func reset():
	state = State.START
	return

func fade_in(time : float):
	var tween : Tween = get_tree().create_tween()
	tween.tween_method(_set_modulate, 0.0, 1.0, time)
	await tween.finished
	return

func fade_out(time : float):
	var tween : Tween = get_tree().create_tween()
	tween.tween_method(_set_modulate, 1.0, 0.0, time)
	await tween.finished
	return

func _set_modulate(value : float):
	self.modulate = Color(1.0, 1.0, 1.0, value)
	sprite_256.modulate = Color(1.0, 1.0, 1.0, value)
	return

func swap_256() -> void:
	sprite_256.texture = data.texture_256_delay
	return

func magnify_enable() -> void:
	sub_viewport_container_256.show()
	return

func magnify_disable() -> void:
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
	state = State.SEARCHING_CLUE_INVISIBLE
	return

func _on_label_end_completed() -> void:
	await get_tree().create_timer(5.0).timeout
	magnify_disable()
	clue_found.emit()
	return

func _on_timer_last_picture_timeout() -> void:
	final_animation_begun.emit()
	animation_player_last_picture.play("flash")
	await animation_player_last_picture.animation_finished
	animation_player_last_picture.play("RESET")
	final_animation_ended.emit()
	return
