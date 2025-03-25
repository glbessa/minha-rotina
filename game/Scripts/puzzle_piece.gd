extends Node2D

var draggable = false
var is_dragging = false
var is_inside_droppable = false
var body_ref
var offset: Vector2
var currentPos: Vector2
var initialPos: Vector2
var placed_correctly = false
var self_puzzle_groups

func _ready():
	initialPos = global_position
	var self_groups = self.get_groups()
	self_puzzle_groups = self_groups.filter(func(group): return group.begins_with("puzzle_"))

func _input(event: InputEvent) -> void:
	if draggable:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not Global.is_dragging:
					Global.is_dragging = true
					currentPos = global_position
					offset = get_global_mouse_position() - global_position
					is_dragging = true
					print("Started Interaction with piece: ", self_puzzle_groups[0])
			else:
				print("Ended Interaction with piece: ", self_puzzle_groups[0])
				Global.is_dragging = false
				is_dragging = false
				var tween = get_tree().create_tween()
				
				if is_inside_droppable and body_ref:
					tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
					tween.connect("finished", Callable(self, "_on_tween_finished"), CONNECT_ONE_SHOT)
				else:
					tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
					tween.connect("finished", Callable(self, "_on_tween_finished"), CONNECT_ONE_SHOT)
				
	if is_dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - offset

func _on_tween_finished():
	if is_inside_droppable and body_ref:
		if is_same_puzzle_group(body_ref):
			if not placed_correctly:
				get_tree().current_scene.add_correct_placement(self_puzzle_groups[0])
				placed_correctly = true
				print("added correct placement for: ", self_puzzle_groups[0])
		elif placed_correctly:
			placed_correctly = false
			get_tree().current_scene.sub_correct_placement(self_puzzle_groups[0])
			print("removed correct placement (new wrong droppable) for: ", self_puzzle_groups[0])
	else:
		if placed_correctly:
			placed_correctly = false
			get_tree().current_scene.sub_correct_placement(self_puzzle_groups[0])
			print("removed correct placement (original pos) for: ", self_puzzle_groups[0])
	
	if not placed_correctly and is_inside_droppable:
		Global.error_count += 1 
		print("Erro #", Global.error_count) 
	if Global.error_count >= 3:
		print("Você cometeu ", Global.error_count, " erros!")
		for body in get_tree().get_nodes_in_group("dropable"):
			body.modulate = Color(1, 1, 1) 
		
		# Encontra o corpo correto para o PEDAÇO ATUAL
		var correct_body: Node2D = null  
		for body in get_tree().get_nodes_in_group("dropable"):
			# Verifica se o corpo tem os mesmos grupos de quebra-cabeça que o PEDAÇO ATUAL
			var body_groups = body.get_groups()
			var body_puzzle_groups = body_groups.filter(func(group): return group.begins_with("puzzle_"))
			if body_puzzle_groups == self_puzzle_groups:
				correct_body = body
				break  
		if correct_body != null:
			correct_body.modulate = Color(0, 1, 0) 
	
func _on_area_2d_mouse_entered() -> void:
	if not is_dragging:
		draggable = true

func _on_area_2d_mouse_exited() -> void:
	if not is_dragging:
		draggable = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		if body_ref != body:
			is_inside_droppable = true
			body.modulate = Color(Color.REBECCA_PURPLE, 1)
			if body_ref:
				body_ref.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
			body_ref = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		if body_ref == body:
			is_inside_droppable = false
			body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
			body_ref = null

func is_same_puzzle_group(bodyref: Node2D) -> bool:
	var self_groups = self.get_groups()
	var body_ref_groups = bodyref.get_groups()
	var body_ref_puzzle_groups = body_ref_groups.filter(func(group): return group.begins_with("puzzle_"))
	
	return self_puzzle_groups == body_ref_puzzle_groups
