extends "res://Levels/level_base.gd"

func _ready():
	next_level_scene = "res://Levels/Level_2.tscn"
	level_index = 0
	super._ready()
