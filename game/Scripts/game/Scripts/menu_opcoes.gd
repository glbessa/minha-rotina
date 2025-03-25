extends Node2D

var label_delay_value: Label
var slider_delay: HSlider
var delay_container

func _ready():
	delay_container = get_tree().get_nodes_in_group("delay")[0]
	label_delay_value = delay_container.get_child(0)
	slider_delay = delay_container.get_child(1)
	
	if label_delay_value is Label:
		label_delay_value.text = str(int(Global.level_start_duration))
	
	slider_delay.value = Global.level_start_duration

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_musica_toggle_toggled(toggled_on: bool) -> void:
	MainMusic.playing = toggled_on

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://menu_inicial.tscn")

func _on_delay_value_changed(value: float) -> void:
	Global.level_start_duration = value
	if label_delay_value is Label:
		label_delay_value.text = str(int(value))
