extends "res://Levels/level_base.gd"

func _ready():
	next_level_scene = "res://Levels/Level_3.tscn"
	level_index = 1
	super._ready()
