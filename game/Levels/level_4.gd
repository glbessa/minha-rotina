extends Node2D  # ou Node, dependendo da sua cena

var level_timer  # Contador do tempo total da fase
var start_time   # Armazena o tempo exato de início da fase
var total_time   # Tempo total gasto na fase
var total_correct_placements = 0  # Total de peças colocadas corretamente
var missplacements = 0  # Número de posicionamentos incorretos
var all_clicks = 0  # Contador de todos os cliques
var level_active = false  # Estado de atividade do nível
var interactions = []  # Array para armazenar interações
var idle_timer = Timer.new()  # Timer para contagem de inatividade
var shadow_nodes = []  # Array para armazenar nós das sombras
var hint_opacity = 0.2  # Opacidade máxima da sombra (ajustável)
var normal_shadow_opacity = 0.0  # Opacidade normal da sombra
var hint1_used = 0  # Contador de dicas tipo 1 usadas
var hint2_used = 0  # Contador de dicas tipo 2 usadas
var using_hint2 = false  # Flag para dica tipo 2 ativa
var timer = Timer  # Referência ao timer principal
var countdown = Label  # Referência ao label de contagem regressiva
var correct_placement = 0  # Peças posicionadas corretamente
var total_puzzle_pieces = 0  # Total de peças do quebra-cabeça
var level_ended = false  # Flag de nível concluído
var finished_count = false  # Flag de contagem finalizada
var completed_pieces = []  # Array de peças completadas
var shadows = []  # Array de sombras
var hint1_active = false  # Flag para dica tipo 1 ativa
var count_to_hint1 = 0  # Contador para ativar dica 1
var was_dragging = false  # Flag para estado anterior de arraste

func _ready():
	timer = $Timer
	countdown = $Countdown
	# Obtém todos os nós no grupo "puzzle"
	var puzzle_nodes = get_tree().get_nodes_in_group("puzzle")
	# Filtra e conta nós StaticBody2D
	total_puzzle_pieces = 0
	for node in puzzle_nodes:
		if node is StaticBody2D:
			total_puzzle_pieces += 1
			
	finished_count = true
	print("Total de Peças do Quebra-Cabeça: " + str(total_puzzle_pieces))
	
	# Esconde todos os elementos do puzzle e do fim do nível
	hide_group("puzzle")
	hide_group("level_end")
	# Mostra todos os elementos do início do nível
	show_group("level_start")
	
	if Global.level_start_duration == 0:
		# Esconde elementos iniciais
		hide_group("level_start")
		# Mostra elementos do puzzle
		show_group("puzzle")
		# Inicia o nível imediatamente
		start_level()
	else:
		timer.wait_time = Global.level_start_duration
		timer.start()
		# Conecta o timeout do timer à função que esconde os elementos iniciais
		timer.connect("timeout", Callable(self, "_on_Timer_timeout"))
		
	shadows = get_tree().get_nodes_in_group("shadow")
	set_process_input(true)

func _process(delta):
	update_countdown()
	# Verifica conclusão do nível
	if correct_placement == total_puzzle_pieces and !level_ended and finished_count:
		# Desconecta e remove o idle timer ao final do nível
		idle_timer.timeout.disconnect(_on_idle_timeout)
		idle_timer.stop()
		remove_child(idle_timer)
		idle_timer.queue_free()
		
		# Reseta a opacidade dos sprites
		show_group("show_hint2")
		for shadow in shadow_nodes:
			shadow.modulate.a = 1.0
			
		# Gerencia visibilidade dos grupos
		hide_group("puzzle")
		hide_group("level_start")
		show_group("level_end")
		level_ended = true
		print("Nível concluído")
		level_timer.stop()
		total_time = (Time.get_ticks_msec() - start_time) / 1000.0  # Converte para segundos
		level_active = false
	
	# Gerencia o timer de inatividade baseado no estado de arraste
	if level_active:
		if Global.is_dragging:
			was_dragging = true
			if idle_timer.is_stopped() == false:
				idle_timer.stop()
				print("Timer Idle Pausado")
		else:
			if was_dragging:
				was_dragging = false
				# Inicia o timer apenas se estava arrastando antes
				if idle_timer.is_stopped():
					idle_timer.start()
					print("Timer Idle iniciado após fim de interação")
			elif idle_timer.is_stopped() and not was_dragging:
				# Inicia o timer se não estava rodando e nunca houve arraste
				idle_timer.start()
				print("Timer Idle iniciado")

func _on_Timer_timeout():
	print("timeout")
	# Esconde elementos iniciais
	hide_group("level_start")
	# Mostra elementos do puzzle
	show_group("puzzle")
	# Desconecta o timer para executar apenas uma vez
	timer.disconnect("timeout", Callable(self, "_on_Timer_timeout"))
	start_level()
	
func _on_idle_timeout():
	# Ativa a dica 2 apenas se não estiver ativa e não estiver arrastando
	if not using_hint2 and not Global.is_dragging:
		using_hint2 = true
		hint2_used += 1
		show_group("show_hint2")
		for shadow in shadow_nodes:
			shadow.modulate.a = hint_opacity

func start_level():
	level_timer = Timer.new()
	level_timer.one_shot = false  # Configura para execução contínua
	add_child(level_timer)
	level_timer.start()
	start_time = Time.get_ticks_msec()
	
	# Inicializa o idle timer mas não inicia ainda
	shadow_nodes = get_tree().get_nodes_in_group("show_hint2")
	add_child(idle_timer)
	idle_timer.wait_time = Global.hint_2_time
	idle_timer.one_shot = false
	idle_timer.timeout.connect(_on_idle_timeout)
	
	level_active = true
	
	# Ativa a verificação de estado de arraste
	set_process(true)

func show_group(group_name: String):
	# Mostra todos os nós de um grupo
	for node in get_tree().get_nodes_in_group(group_name):
		node.visible = true

func hide_group(group_name: String):
	# Esconde todos os nós de um grupo
	for node in get_tree().get_nodes_in_group(group_name):
		node.visible = false
		
func update_countdown():
	# Atualiza o texto da contagem regressiva
	countdown.text = str(int(ceil(timer.time_left)))
	
func add_correct_placement(group_name: String):
	# Adiciona uma peça corretamente posicionada
	if group_name not in completed_pieces:
		completed_pieces.append(group_name)
		correct_placement += 1
		total_correct_placements += 1
		count_to_hint1 = 0 # reseta a contagem para a dica 1
		print("Contagem para a dica 1 resetada")
		if hint1_active:
			print("Dica 1 desativada")
			hint1_active = false
			for shadow in shadows:
				shadow.color = (Color(Color.MEDIUM_PURPLE, 0.7))

func sub_correct_placement(group_name: String):
	# Remove uma peça corretamente posicionada
	if group_name in completed_pieces:
		completed_pieces.erase(group_name)
		correct_placement -= 1

func add_incorrect_placement():
	# Registra um posicionamento incorreto
	missplacements += 1
	count_to_hint1 += 1

func enable_hint1(piece):
	# Ativa a dica 1 apenas se estiver marcada como ativa
	print('Contagem até a dica = ', count_to_hint1)
	if hint1_active:
		var sombra_correspondente = piece + "_shadow"
		
		# Primeiro reseta todas as sombras
		for shadow in shadows:
			shadow.color = (Color(Color.MEDIUM_PURPLE, 0.7))
		
		# Depois destaca apenas a sombra da peça atual
		for shadow in shadows:
			if shadow.name == sombra_correspondente:
				shadow.color = (Color(Color(0,1,0), 0.7))  # Verde para dica
				print("Dica 1 ativada")

func _input(event: InputEvent) -> void:
	# Registra cliques durante o nível ativo
	if event is InputEventMouseButton and event.pressed and level_active:
		all_clicks += 1

func add_interaction():
	# Adiciona uma interação com timestamp
	var current_time = (Time.get_ticks_msec() - start_time) / 1000.0
	interactions.append(current_time)
	
	# Ativa dica 1 se atingir o limite
	if count_to_hint1 >= Global.hint_1_count:
		hint1_active = true	

	# Desativa dica 2 se estiver ativa
	if using_hint2:
		using_hint2 = false
		for shadow in shadow_nodes:
			shadow.modulate.a = normal_shadow_opacity  # Volta à opacidade normal

func _on_next_level_button_pressed() -> void:
	Statistics.register_total_time(3, total_time)
	Statistics.register_hints(3, hint1_used, hint2_used)
	Statistics.register_all_clicks(3, all_clicks)
	Statistics.register_all_interactions(3, interactions)
	Statistics.register_missplacement_error(3, missplacements)
	Statistics.register_correct_pieces(3, total_correct_placements)
	get_tree().change_scene_to_file("res://Menu/menu_inicial.tscn")
