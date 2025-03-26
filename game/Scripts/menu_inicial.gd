extends Node2D


func _on_button_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu/menu_opcoes.tscn")


func _on_button_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Levels/Level_1.tscn")
