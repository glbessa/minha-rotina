extends Node2D  # Ou "Node", dependendo do seu jogo

var timer = Timer
var countdown = Label
var correct_placement = 0
var total_puzzle_pieces = 0
var level_ended = false
var finished_count = false
var completed_pieces = []

@export var next_level_path: String  # Definimos a próxima fase diretamente no Editor

func _ready():
	timer = $Timer
	countdown = $Countdown
	var puzzle_nodes = get_tree().get_nodes_in_group("puzzle")
	
	total_puzzle_pieces = 0
	for node in puzzle_nodes:
		if node is StaticBody2D:
			total_puzzle_pieces += 1

	finished_count = true
	print("Total Puzzle Pieces: " + str(total_puzzle_pieces))

	hide_group("puzzle")
	hide_group("level_end")
	show_group("level_start")

	if Global.level_start_duration == 0:
		hide_group("level_start")
		show_group("puzzle")
	else:
		timer.wait_time = Global.level_start_duration
		timer.start()
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
	hide_group("level_start")
	show_group("puzzle")
	timer.disconnect("timeout", Callable(self, "_on_Timer_timeout"))

func show_group(group_name: String):
	for node in get_tree().get_nodes_in_group(group_name):
		node.visible = true

func hide_group(group_name: String):
	for node in get_tree().get_nodes_in_group(group_name):
		node.visible = false

func update_countdown():
	countdown.text = str(int(ceil(timer.time_left)))

func add_correct_placement(group_name: String):
	if group_name not in completed_pieces:
		completed_pieces.append(group_name)
		correct_placement += 1
		print("list of completed pieces: ",completed_pieces)

func sub_correct_placement(group_name: String):
	if group_name in completed_pieces:
		completed_pieces.erase(group_name)
		correct_placement -= 1
		print("list of completed pieces: ",completed_pieces)

func _on_next_level_button_pressed() -> void:
	if next_level_path != "":
		get_tree().change_scene_to_file(next_level_path)
