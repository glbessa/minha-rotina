extends Node2D

# Variáveis de controle
var draggable = false  # Se a peça pode ser arrastada
var is_dragging = false  # Se a peça está sendo arrastada no momento
var is_inside_droppable = false  # Se a peça está sobre uma área de soltar válida
var body_ref  # Referência para a área de soltar atual
var offset: Vector2  # Distância entre o toque e o centro da peça
var currentPos: Vector2  # Posição atual da peça
var initialPos: Vector2  # Posição inicial da peça (para reset)
var placed_correctly = false  # Se a peça está colocada no lugar certo
var self_puzzle_groups  # Grupos de puzzle que esta peça pertence
var was_just_pressed = false  # Flag para controle de toque na tela

func _ready():
	# Guarda a posição inicial e filtra os grupos de puzzle
	initialPos = global_position
	var self_groups = self.get_groups()
	# Pega apenas os grupos que começam com "puzzle_"
	self_puzzle_groups = self_groups.filter(func(group): return group.begins_with("puzzle_"))

func _input(event: InputEvent) -> void:
	if not is_level_active():
		return
	# Verifica se é um clique do mouse ou toque na tela
	if (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT) or event is InputEventScreenTouch:
		# Pega a posição do toque/mouse
		var touch_pos = event.position if event is InputEventScreenTouch else get_global_mouse_position()
		var area = $Area2D
		# Converte para coordenadas locais da área
		var local_pos = area.to_local(touch_pos)
		# Pega o formato de colisão da área
		var shape = area.shape_owner_get_shape(0, 0) if area.get_shape_owners().size() > 0 else null
		
		# Quando toca na tela/clica
		if event.is_pressed():
			was_just_pressed = true
			# Verifica se o toque está dentro do retângulo da peça
			if shape and shape is RectangleShape2D:
				var rect = Rect2(-shape.size/2, shape.size)
				if rect.has_point(local_pos) and not Global.is_dragging:
					draggable = true
					start_dragging(touch_pos)
		# Quando solta o toque/clique
		else:
			if is_dragging:
				stop_dragging()
			draggable = false
			was_just_pressed = false
	
	# Movimento durante o arrasto
	if is_dragging and (event is InputEventMouseMotion or event is InputEventScreenDrag):
		global_position = get_global_mouse_position() - offset

# Inicia o arrasto da peça
func start_dragging(touch_pos: Vector2):
	if not is_level_active():
		return
	print("Started Interaction with piece: ", self_puzzle_groups[0])
	Global.is_dragging = true  # Marca globalmente que uma peça está sendo arrastada
	currentPos = global_position
	# Calcula o offset entre o toque e o centro da peça
	offset = touch_pos - global_position
	is_dragging = true
	# Registra a interação com a cena
	get_tree().current_scene.add_interaction()
	get_tree().current_scene.enable_hint1(self_puzzle_groups[0])

# Finaliza o arrasto da peça
func stop_dragging():
	if not is_level_active():
		return
	print("Ended Interaction with piece: ", self_puzzle_groups[0])
	Global.is_dragging = false
	is_dragging = false
	var tween = get_tree().create_tween()
	
	# Se estiver sobre uma área válida, encaixa a peça
	if is_inside_droppable and body_ref:
		tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
		tween.connect("finished", Callable(self, "_on_tween_finished"), CONNECT_ONE_SHOT)
	# Senão, volta para a posição inicial
	else:
		tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
		tween.connect("finished", Callable(self, "_on_tween_finished"), CONNECT_ONE_SHOT)
		
# Chamado quando a animação de movimento termina
func _on_tween_finished():
	if is_inside_droppable and body_ref:
		# Verifica se colocou no lugar certo
		if is_same_puzzle_group(body_ref):
			if !placed_correctly:
				# Primeira vez colocando corretamente
				get_tree().current_scene.add_correct_placement(self_puzzle_groups[0])
				placed_correctly = true
				print("added correct placement for: ", self_puzzle_groups[0])
		elif placed_correctly:
			# Movendo de um lugar correto para um errado
			placed_correctly = false
			get_tree().current_scene.sub_correct_placement(self_puzzle_groups[0])
			print("removed correct placement (new wrong droppable) for: ", self_puzzle_groups[0])
			get_tree().current_scene.add_incorrect_placement()
		else:
			# Colocando em lugar errado
			get_tree().current_scene.add_incorrect_placement()
	else:
		if placed_correctly:
			# Voltando para posição inicial de um lugar correto
			placed_correctly = false
			get_tree().current_scene.sub_correct_placement(self_puzzle_groups[0])
			print("removed correct placement (original pos) for: ", self_puzzle_groups[0])

# Quando entra em uma área de soltar
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		if body_ref != body:
			is_inside_droppable = true
			# Muda a cor para indicar área ativa
			body.modulate = Color(Color.REBECCA_PURPLE, 1)
			if body_ref:
				# Restaura cor da área anterior
				body_ref.modulate = Color(Color.MEDIUM_PURPLE, 0.7) 
			body_ref = body

# Quando sai de uma área de soltar
func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		if body_ref == body:
			is_inside_droppable = false
			# Restaura cor da área
			body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
			body_ref = null 

# Verifica se a peça e a área são do mesmo grupo de puzzle
func is_same_puzzle_group(bodyref: Node2D) -> bool:
	var self_groups = self.get_groups()
	var body_ref_groups = bodyref.get_groups()
	
	# Filtra apenas grupos de puzzle
	var body_ref_puzzle_groups = body_ref_groups.filter(func(group): return group.begins_with("puzzle_"))
	
	# Compara os grupos
	return self_puzzle_groups == body_ref_puzzle_groups
	
func is_level_active() -> bool:
	var is_active = get_tree().current_scene.is_level_active()
	return is_active
