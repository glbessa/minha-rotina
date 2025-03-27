extends Node2D

var label_delay_value: Label
var slider_delay: HSlider
var delay_container

var label_hint1_value: Label
var slider_hint1: HSlider
var hint1_container

var label_hint2_value: Label
var slider_hint2: HSlider
var hint2_container

func _ready():
	delay_container = get_tree().get_nodes_in_group("delay")[0]
	label_delay_value = delay_container.get_child(0)
	slider_delay = delay_container.get_child(1)
	
	label_delay_value.text = str(int(Global.level_start_duration))
	slider_delay.value = Global.level_start_duration
	
	hint1_container = get_tree().get_nodes_in_group("hint1")[0]
	label_hint1_value = hint1_container.get_child(0)
	slider_hint1 = hint1_container.get_child(1)
	
	label_hint1_value.text = str(int(Global.hint_1_count))
	slider_hint1.value = Global.hint_1_count
	
	hint2_container = get_tree().get_nodes_in_group("hint2")[0]
	label_hint2_value = hint2_container.get_child(0)
	slider_hint2 = hint2_container.get_child(1)
	
	label_hint2_value.text = str(int(Global.hint_2_time))
	slider_hint2.value = Global.hint_2_time
	

	var volume_slider = $PanelContainer/MarginContainer/VBoxContainer/volume
	volume_slider.value = AudioServer.get_bus_volume_db(0)

func _on_volume_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, value)

func _on_musica_toggle_toggled(toggled_on: bool) -> void:
	MainMusic.playing = toggled_on

func _on_voltar_pressed() -> void:
	get_tree().change_scene_to_file("res://Menu/menu_inicial.tscn")

func _on_delay_value_changed(value: float) -> void:
	Global.level_start_duration = value
	label_delay_value.text = str(int(value))


func _on_hint_1_value_changed(value: float) -> void:
	Global.hint_1_count = value
	label_hint1_value.text = str(int(value))


func _on_hint_2_value_changed(value: float) -> void:
	Global.hint_2_time = value
	label_hint2_value.text = str(int(value))
