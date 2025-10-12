class_name Main
extends Node

const PICTURE : PackedScene = preload("res://scenes/picture/picture.tscn")
const DATA_PARK : PictureData = preload("res://data/park.tres")
const DATA_RECESS : PictureData = preload("res://data/recess.tres")
const DATA_CHURCH : PictureData = preload("res://data/church.tres")
const DATA_LOT : PictureData = preload("res://data/lot.tres")
const DATA_FOREST : PictureData = preload("res://data/forest.tres")
const DATA_SOCCER : PictureData = preload("res://data/soccer.tres")
const DATA_MAIN_STREET : PictureData = preload("res://data/main_street.tres")
const DATA_BARN : PictureData = preload("res://data/barn.tres")
const DATA_TUBING : PictureData = preload("res://data/tubing.tres")
const DATA_RESTAURANT : PictureData = preload("res://data/restaurant.tres")
const DATA_PORTAIT : PictureData = preload("res://data/portrait.tres")

const NUM_PICTURES : int = 11

enum State
{
	START,
	NEXT_PICTURE,
	SHOW_PICTURE,
	THIRD_NARRATION,
	SIXTH_NARRATION,
	FINAL_PICTURE,
	END
}

var state : State

var picture : Picture = null
var pictures : Array[PictureData] = [
	DATA_PARK,
	DATA_RECESS,
	DATA_CHURCH,
	DATA_LOT,
	DATA_FOREST,
	DATA_SOCCER,
	DATA_MAIN_STREET,
	DATA_BARN,
	DATA_TUBING,
	DATA_RESTAURANT
]
var index_picture : int = -1

var audio_manager : AudioManager = null
var color_rect_black : ColorRect = null
var label_narration : LabelNarration = null

func _ready() -> void:
	audio_manager = %AudioManager
	color_rect_black = %ColorRectBlack
	label_narration = %LabelNarration
	
	audio_manager.play("MUSIC")
	
	picture = PICTURE.instantiate()
	add_child(picture)
	
	picture.clue_found.connect(_on_picture_clue_found)
	picture.final_animation_begun.connect(_on_picture_final_animation_begun)
	picture.final_animation_ended.connect(_on_picture_final_animation_ended)
	
	# shuffle the first ten pictures and make sure portrait is the last picture
	pictures.shuffle()
	pictures.push_back(DATA_PORTAIT)
	
	state = State.START
	return

func show_picture() -> void:
	picture.reset()
	picture.data = pictures[index_picture]
	return

func show_final_picture() -> void:
	audio_manager.fade_out("MUSIC", 5.0)
	audio_manager.play("VIOLINS_PLUCKING")
	picture.reset()
	picture.data = pictures[index_picture]
	return

func fade_to_black(time_to_black : float, post_delay : float) -> void:
	var tween : Tween = get_tree().create_tween()
	tween.tween_method(set_color_rect_alpha, 0.0, 1.0, time_to_black)
	await tween.finished
	await get_tree().create_timer(post_delay).timeout
	return

func set_color_rect_alpha(value : float) -> void:
	color_rect_black.color.a = value
	return

func play_opening_narration() -> void:
	
	return

func play_third_narration() -> void:
	
	return

func play_sixth_narration() -> void:
	
	return

func play_final_narration() -> void:
	label_narration.text = "YOU ARE NEXT"
	label_narration.add_theme_font_size_override("m3x6", 32)
	label_narration.character_delay_time = 0.0
	label_narration.index_char_target = 3
	audio_manager.play("PIANO")
	await label_narration.target_reached
	await get_tree().create_timer(1.0).timeout
	label_narration.index_char_target = 7
	audio_manager.play("PIANO")
	await label_narration.target_reached
	await get_tree().create_timer(1.0).timeout
	label_narration.index_char_target = label_narration.text.length()
	audio_manager.play("PIANO")
	await label_narration.target_reached
	await get_tree().create_timer(5.0).timeout
	return

func _set_state(value : State) -> void:
	state = value
	_on_state_changed()
	return

func _on_state_changed() -> void:
	match state:
		State.START:
			play_opening_narration()
			state = State.NEXT_PICTURE
		State.NEXT_PICTURE:
			index_picture += 1
			if(index_picture == 3):
				state = State.THIRD_NARRATION
			elif(index_picture == 6):
				state = State.SIXTH_NARRATION
			elif(index_picture == NUM_PICTURES - 1):
				state = State.FINAL_PICTURE 
			else:
				state = State.SHOW_PICTURE
		State.SHOW_PICTURE:
			label_narration.hide()
			show_picture()
		State.THIRD_NARRATION:
			play_third_narration()
			state = State.SHOW_PICTURE
		State.SIXTH_NARRATION:
			play_sixth_narration()
			state = State.SHOW_PICTURE
		State.FINAL_PICTURE:
			show_final_picture()
			state = State.END
		State.END:
			play_final_narration()
			fade_to_black(5.0, 2.0)
			get_tree().reload_current_scene()
		_:
			print("error: invalid state - ", state)
			pass
	return

func _on_picture_clue_found() -> void:
	state = State.NEXT_PICTURE
	return

func _on_picture_final_animation_begun() -> void:
	audio_manager.stop_all()
	audio_manager.play("VIOLINS_SCREECHING")
	return

func _on_picture_final_animation_ended() -> void:
	state = State.END
	return
