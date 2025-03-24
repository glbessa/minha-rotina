extends Node2D  # or Node, depending on your scene

var timer = Timer
var countdown = Label
var correct_placement = 0
var total_puzzle_pieces = 0
var level_ended = false
var finished_count = false

func _ready():
	timer = $Timer
	countdown = $Countdown
	# Get all nodes in the "puzzle" group
	var puzzle_nodes = get_tree().get_nodes_in_group("puzzle")
	# Filter and count StaticBody2D nodes
	total_puzzle_pieces = 0
	for node in puzzle_nodes:
		if node is StaticBody2D:
			total_puzzle_pieces += 1
			
	finished_count = true
	print("Total Puzzle Pieces: " + str(total_puzzle_pieces))
	
	# Hide all puzzle and level_end elements
	hide_group("puzzle")
	hide_group("level_end")
	# Unhide all start elements
	show_group("level_start")
	
	if Global.level_start_duration == 0:
		# Hide all start elements
		hide_group("level_start")
		# Unhide all puzzle elements
		show_group("puzzle")
	else:
		timer.wait_time = Global.level_start_duration
		timer.start()
		# Connect the timer's timeout to the function that hides the start elements
		timer.connect("timeout", Callable(self, "_on_Timer_timeout"))

func _process(delta):
	update_countdown()
	
	if correct_placement == total_puzzle_pieces and !level_ended and finished_count:
		hide_group("puzzle")
		hide_group("level_start")
		show_group("level_end")
		level_ended = true
		print("Level completed")

func _on_Timer_timeout():
	print("timeout")
	# Hide all start elements
	hide_group("level_start")
	# Unhide all puzzle elements
	show_group("puzzle")
	# Disconnects the timer so it only timeouts once
	timer.disconnect("timeout", Callable(self, "_on_Timer_timeout"))

func show_group(group_name: String):
	for node in get_tree().get_nodes_in_group(group_name):
		node.visible = true

func hide_group(group_name: String):
	for node in get_tree().get_nodes_in_group(group_name):
		node.visible = false
		
func update_countdown():
	countdown.text = str(int(ceil(timer.time_left)))
	
func add_correct_placement():
	correct_placement = correct_placement + 1;
	
func sub_correct_placement():
	correct_placement = correct_placement - 1;
	
func _on_next_level_button_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_inicial.tscn") # TODO: change to next level
