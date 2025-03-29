extends Node

var is_dragging = false
var level_start_duration = 5
var hint_1_count = 3
var hint_2_time = 15
var save_path = "user://game_data.xml"  # Valor padrão

func _ready():
	load_save_path()  # Carregar valor salvo ao iniciar

func save_save_path():
	var config = ConfigFile.new()
	config.set_value("settings", "save_path", save_path)
	config.save("user://config.cfg")  # Salva no arquivo

func load_save_path():
	var config = ConfigFile.new()
	var err = config.load("user://config.cfg")
	if err == OK:  # Se o arquivo existir, carrega o valor salvo
		save_path = config.get_value("settings", "save_path", save_path)
