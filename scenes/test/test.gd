class_name Test
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

var picture : Picture = null

func _ready() -> void:
	picture = PICTURE.instantiate()
	add_child(picture)
	picture.data = DATA_PORTAIT
	return
