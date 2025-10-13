class_name Main
extends Node

signal enter

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

const NARRATION_LINE_DELAY : float = 4.0
const CHARACTER_DELAY_NORMAL : float = 0.03
const CHARACTER_DELAY_SLOW : float = 0.06
const CHARACTER_DELAY_FAST : float = 0.00

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

var state : State : set = _set_state

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
var label_top : LabelDelay = null
var label_bottom : LabelDelay = null
var label_narration : LabelDelay = null

func _ready() -> void:
	audio_manager = %AudioManager
	color_rect_black = %ColorRectBlack
	label_top = %LabelTop
	label_bottom = %LabelBottom
	label_narration = %LabelNarration
	
	picture = PICTURE.instantiate()
	add_child(picture)
	
	picture.waiting_to_spawn.connect(_on_picture_waiting_to_spawn)
	picture.searching_clue_invisible.connect(_on_picture_searching_clue_invisible)
	picture.searching_clue_visible.connect(_on_picture_searching_clue_visible)
	picture.clue_seen.connect(_on_picture_clue_seen)
	picture.clue_found.connect(_on_picture_clue_found)
	picture.final_animation_begun.connect(_on_picture_final_animation_begun)
	
	# shuffle the first ten pictures and make sure portrait is the last picture
	pictures.shuffle()
	pictures.push_back(DATA_PORTAIT)
	
	state = State.START
	return

func _unhandled_input(event: InputEvent) -> void:
	if(event.is_action_pressed("ENTER")):
		enter.emit()
	return

func show_picture() -> void:
	picture.reset()
	picture.data = pictures[index_picture]
	label_top.snap_in()
	label_bottom.snap_in()
	await picture.fade_in(1.0)
	return

func show_final_picture() -> void:
	audio_manager.fade_out("MUSIC", 5.0)
	audio_manager.play("VIOLINS_PLUCKING")
	picture.reset()
	picture.data = pictures[index_picture]
	label_top.snap_in()
	label_bottom.snap_in()
	await picture.fade_in(1.0)
	label_top.text = pictures[index_picture].start_text
	label_top.character_delay_time = CHARACTER_DELAY_SLOW
	label_top.index_char_target = 18
	await label_top.target_reached
	await get_tree().create_timer(1.0).timeout
	label_top.index_char_target = 24
	await label_top.target_reached
	await get_tree().create_timer(1.0).timeout
	label_top.index_char_target = 38
	await label_top.target_reached
	await get_tree().create_timer(1.0).timeout
	label_top.index_char_target = label_top.text.length()
	await picture.final_animation_begun
	audio_manager.play("VIOLINS_SCREECHING")
	await picture.final_animation_ended
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
	label_top.reset()
	label_bottom.reset()
	label_narration.show()
	label_narration.index_char_current = 0
	label_narration.character_delay_time = CHARACTER_DELAY_NORMAL
	label_narration.text = "As you have heard, South Fork, Iowa is gone. Nothing now but dust and ruin.\n\nNothing has been recovered, except photos scattered throughout the wreckage.\n\nTheir subjects appear benign; we can't tell what their purpose is. We are missing something.\n\nWe need someone with your skillset to examine them. Tell us what you see."
	label_narration.index_char_target = 75
	await label_narration.target_reached
	await get_tree().create_timer(NARRATION_LINE_DELAY).timeout
	label_narration.index_char_target = 153
	await label_narration.target_reached
	await get_tree().create_timer(NARRATION_LINE_DELAY).timeout
	label_narration.index_char_target = 247
	await label_narration.target_reached
	await get_tree().create_timer(NARRATION_LINE_DELAY).timeout
	label_narration.index_char_target = label_narration.text.length()
	await label_narration.target_reached
	await enter
	return

func play_third_narration() -> void:
	label_top.reset()
	label_bottom.reset()
	label_narration.show()
	label_narration.index_char_current = 0
	label_narration.character_delay_time = CHARACTER_DELAY_NORMAL
	label_narration.text = "These photos feel familiar somehow. It's hard to explain.\n\nHave I seen them before? I can almost remember this town, though I've never been there.\n\nI've stared so long, and yet I can't see the things you do. Maybe if I keep looking..."
	label_narration.index_char_target = 57
	await label_narration.target_reached
	await get_tree().create_timer(NARRATION_LINE_DELAY).timeout
	label_narration.index_char_target = 146
	await label_narration.target_reached
	await get_tree().create_timer(NARRATION_LINE_DELAY).timeout
	label_narration.index_char_target = label_narration.text.length()
	await label_narration.target_reached
	await enter
	return

func play_sixth_narration() -> void:
	label_top.reset()
	label_bottom.reset()
	label_narration.show()
	label_narration.index_char_current = 0
	label_narration.character_delay_time = CHARACTER_DELAY_NORMAL
	label_narration.text = "I feel different. The photos call to me.\n\nI can feel them, like a thought tickling the back of my brain.\n\nWe must hurry. Something feels very wrong."
	label_narration.index_char_target = 40
	await label_narration.target_reached
	await get_tree().create_timer(NARRATION_LINE_DELAY).timeout
	label_narration.index_char_target = 104
	await label_narration.target_reached
	await get_tree().create_timer(NARRATION_LINE_DELAY).timeout
	label_narration.index_char_target = label_narration.text.length()
	await label_narration.target_reached
	await enter
	return

func play_final_narration() -> void:
	label_top.reset()
	label_bottom.reset()
	label_narration.show()
	label_narration.add_theme_font_size_override("font_size", 32)
	label_narration.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label_narration.index_char_current = 0
	label_narration.text = "YOU ARE NEXT"
	label_narration.character_delay_time = CHARACTER_DELAY_FAST
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
			audio_manager.play("MUSIC")
			await play_opening_narration()
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
			await play_third_narration()
			state = State.SHOW_PICTURE
		State.SIXTH_NARRATION:
			await play_sixth_narration()
			state = State.SHOW_PICTURE
		State.FINAL_PICTURE:
			await show_final_picture()
			state = State.END
		State.END:
			await play_final_narration()
			await fade_to_black(5.0, 2.0)
			get_tree().reload_current_scene()
		_:
			print("error: invalid state - ", state)
			pass
	return

func _on_picture_waiting_to_spawn() -> void:
	label_top.text = pictures[index_picture].start_text
	label_top.index_char_target = label_top.text.length()
	return

func _on_picture_searching_clue_invisible() -> void:
	
	return

func _on_picture_searching_clue_visible() -> void:
	
	return

func _on_picture_clue_seen() -> void:
	audio_manager.play("PIANO")
	return

func _on_picture_clue_found() -> void:
	label_bottom.index_char_current = 0
	label_bottom.text = pictures[index_picture].end_text
	label_bottom.character_delay_time = 0.03
	label_bottom.index_char_target = label_bottom.text.length()
	await label_bottom.target_reached
	await get_tree().create_timer(5.0).timeout
	label_top.fade_out(1.0)
	label_bottom.fade_out(1.0)
	await picture.fade_out(1.0)
	label_top.reset()
	label_bottom.reset()
	state = State.NEXT_PICTURE
	return

func _on_picture_final_animation_begun() -> void:
	audio_manager.stop_all()
	audio_manager.play("VIOLINS_SCREECHING")
	return
