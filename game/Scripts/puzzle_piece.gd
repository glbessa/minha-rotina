extends Node2D

var draggable = false
var is_dragging = false  # Local dragging state for each piece
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
				if not Global.is_dragging:  # Check if no other piece is being dragged
					Global.is_dragging = true  # Set global dragging state
					currentPos = global_position
					offset = get_global_mouse_position() - global_position
					is_dragging = true  # Local dragging state set to true
					print("Started Interaction with piece: ",self_puzzle_groups[0])
			else:
				print("Ended Interaction with piece: ",self_puzzle_groups[0])
				Global.is_dragging = false  # Clear global dragging state when released
				is_dragging = false  # Local dragging state set to false
				var tween = get_tree().create_tween()
				
				if is_inside_droppable and body_ref:
					# Snap to the global position of the most recently entered droppable area
					tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
					
					# Connect the tween's finished signal to a function that handles placement logic
					tween.connect("finished", Callable(self, "_on_tween_finished"), CONNECT_ONE_SHOT)
				else:
					# Return to the initial position
					tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
					
					# Connect the tween's finished signal to a function that handles placement logic
					tween.connect("finished", Callable(self, "_on_tween_finished"), CONNECT_ONE_SHOT)
				
	if is_dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - offset

func _on_tween_finished():
	if is_inside_droppable and body_ref:
		if is_same_puzzle_group(body_ref):
			if !placed_correctly:
				# New correct placement
				get_tree().current_scene.add_correct_placement(self_puzzle_groups[0])
				placed_correctly = true
				print("added correct placement for: ", self_puzzle_groups[0])
			# If already placed correctly, do nothing (it's the same droppable)
		elif placed_correctly:
			# Moved to wrong droppable
			placed_correctly = false
			get_tree().current_scene.sub_correct_placement(self_puzzle_groups[0])
			print("removed correct placement (new wrong droppable) for: ", self_puzzle_groups[0])
	else:
		if placed_correctly:
			# Returned to initial position
			placed_correctly = false
			get_tree().current_scene.sub_correct_placement(self_puzzle_groups[0])
			print("removed correct placement (original pos) for: ", self_puzzle_groups[0])

func _on_area_2d_mouse_entered() -> void:
	if not is_dragging:
		draggable = true

func _on_area_2d_mouse_exited() -> void:
	if not is_dragging:
		draggable = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		# Update the reference to the last entered area
		if body_ref != body:
			is_inside_droppable = true
			body.modulate = Color(Color.REBECCA_PURPLE, 1)
			if body_ref:
				body_ref.modulate = Color(Color.MEDIUM_PURPLE, 0.7)  # Reset the previous area to its original color
			body_ref = body  # Update to the new body area

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		# Only clear the reference if it was the last entered area
		if body_ref == body:
			is_inside_droppable = false
			body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)
			body_ref = null  # Clear the reference

func is_same_puzzle_group(bodyref: Node2D) -> bool:
	# Get all groups for self and the referenced body
	var self_groups = self.get_groups()
	var body_ref_groups = bodyref.get_groups()
	
	# Filter groups that start with "puzzle_"
	var body_ref_puzzle_groups = body_ref_groups.filter(func(group): return group.begins_with("puzzle_"))
	
	# Compare the filtered puzzle groups
	return self_puzzle_groups == body_ref_puzzle_groups
