extends "res://Levels/level_base.gd"

func _ready():
	next_level_scene = "res://Levels/Level_4.tscn"
	level_index = 2
	super._ready()
