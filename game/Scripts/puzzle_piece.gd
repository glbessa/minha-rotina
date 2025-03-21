extends Node2D

var draggable = false
var is_dragging = false  # Local dragging state for each piece
var is_inside_droppable = false
var body_ref
var offset: Vector2
var currentPos: Vector2
var initialPos: Vector2

func _ready():
	initialPos = global_position

func _input(event: InputEvent) -> void:
	if draggable:
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				if not Global.is_dragging:  # Check if no other piece is being dragged
					Global.is_dragging = true  # Set global dragging state
					currentPos = global_position
					offset = get_global_mouse_position() - global_position
					is_dragging = true  # Local dragging state set to true
			else:
				Global.is_dragging = false  # Clear global dragging state when released
				is_dragging = false  # Local dragging state set to false
				var tween = get_tree().create_tween()
				
				if is_inside_droppable and body_ref:
					# Snap to the global position of the most recently entered droppable area
					tween.tween_property(self, "global_position", body_ref.global_position, 0.2).set_ease(Tween.EASE_OUT)
				else:
					# Return to the initial position
					tween.tween_property(self, "global_position", initialPos, 0.2).set_ease(Tween.EASE_OUT)
				
	if is_dragging and event is InputEventMouseMotion:
		global_position = get_global_mouse_position() - offset

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
