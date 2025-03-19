extends Node2D


func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)


func _on_musica_toggle_toggled(toggled_on: bool) -> void:
	MainMusic.playing = toggled_on;


func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_inicial.tscn")
