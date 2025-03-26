extends Node2D  # or Node, depending on your scene

var level_timer  # Para contar o tempo total da fase
var start_time   # Guarda o tempo exato de início da fase
var total_time   # Tempo gasto na fase
var total_correct_placements = 0
var missplacements = 0
var all_clicks = 0
var level_active = false
var interactions = []
var idle_timer = Timer.new()  # Timer para contar inatividade
var shadow_nodes = []         # Array para armazenar os nós das sombras
var hint_opacity = 0.2  # Opacidade máxima da sombra (ajuste conforme necessário)
var normal_shadow_opacity = 0.0  # Opacidade normal da sombra
var hint1_used = 0
var hint2_used = 0
var using_hint2 = false
var timer = Timer
var countdown = Label
var correct_placement = 0
var total_puzzle_pieces = 0
var level_ended = false
var finished_count = false
var completed_pieces = []
var shadows = []
var hint1_active = false
var count_to_hint1 = 0

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
		
	shadows = get_tree().get_nodes_in_group("shadow")
	set_process_input(true)

func _process(delta):
	update_countdown()
	if correct_placement == total_puzzle_pieces and !level_ended and finished_count:
		hide_group("puzzle")
		hide_group("level_start")
		show_group("level_end")
		level_ended = true
		print("Level completed")
		level_timer.stop()
		total_time = (Time.get_ticks_msec() - start_time) / 1000.0  # Converte para segundos
		level_active = false

func _on_Timer_timeout():
	print("timeout")
	# Hide all start elements
	hide_group("level_start")
	# Unhide all puzzle elements
	show_group("puzzle")
	# Disconnects the timer so it only timeouts once
	timer.disconnect("timeout", Callable(self, "_on_Timer_timeout"))
	level_timer = Timer.new()
	level_timer.one_shot = false  # Faz com que ele rode continuamente
	add_child(level_timer)  # Adiciona o temporizador ao nó
	level_timer.start()
	start_time = Time.get_ticks_msec()  # Marca o tempo inicial
	level_active = true
	
	add_child(idle_timer)
	idle_timer.wait_time = 15.0
	idle_timer.one_shot = false
	idle_timer.timeout.connect(_on_idle_timeout)
	idle_timer.start()
	shadow_nodes = get_tree().get_nodes_in_group("show_hint2")
	
func _on_idle_timeout():
	if not using_hint2:
		using_hint2 = true
		hint2_used += 1
		show_group("show_hint2")
		for shadow in shadow_nodes:
			shadow.modulate.a = hint_opacity  # Aumenta a opacidade para mostrar a dica

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
		total_correct_placements += 1

func sub_correct_placement(group_name: String):
	if group_name in completed_pieces:
		completed_pieces.erase(group_name)
		correct_placement -= 1

func add_incorrect_placement():
	missplacements += 1
	count_to_hint1 += 1

func enable_hint1(piece):
	if hint1_active:
		hint1_used += 1
		var sombra_correspondente = piece + "_shadow"
		
		for shadow in shadows:
			if shadow.name == sombra_correspondente:
				shadow.color = Color(0, 1, 0)

func disable_hint1():
	print('Contagem até o hint = ', count_to_hint1)
	if hint1_active:
		count_to_hint1 = 0
	hint1_active = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and level_active:
		all_clicks += 1

func add_interaction():
	var current_time = (Time.get_ticks_msec() - start_time) / 1000.0
	interactions.append(current_time)  # Guarda como string formatada
	
	if count_to_hint1 >= 3:
		hint1_active = true

	if using_hint2:
		using_hint2 = false
		for shadow in shadow_nodes:
			shadow.modulate.a = normal_shadow_opacity  # Volta à opacidade normal

func _on_next_level_button_pressed() -> void:
	Statistics.register_total_time(0, total_time)
	Statistics.register_hints(0, hint1_used, hint2_used)
	Statistics.register_all_clicks(0, all_clicks)
	Statistics.register_all_interactions(0, interactions)
	Statistics.register_missplacement_error(0, missplacements)
	Statistics.register_correct_pieces(0, total_correct_placements)
	get_tree().change_scene_to_file("res://Levels/Level_2.tscn")
