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

var filepath_label: Label
var select_button: Button
var file_dialog: FileDialog

func _ready():
	OS.request_permissions()
	
	# Obtendo os elementos da interface gráfica
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
	
	filepath_label = get_tree().get_nodes_in_group("filepath")[0]
	select_button = get_tree().get_nodes_in_group("filepath")[1]
	select_button.text = Global.save_path
	
	var volume_slider = $PanelContainer/MarginContainer/VBoxContainer/volume
	volume_slider.value = AudioServer.get_bus_volume_db(0)
	
	# Configuração do diálogo de arquivos
	file_dialog = FileDialog.new()
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dialog.filters = ["*.xml"]
	file_dialog.file_selected.connect(_on_file_selected)
	file_dialog.dir_selected.connect(_on_dir_selected)
	file_dialog.canceled.connect(_on_file_dialog_canceled)
	add_child(file_dialog)
	
	select_button.pressed.connect(_on_select_path_button_pressed)

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
	
	file_dialog.current_file = "save_data.dat"
	file_dialog.popup_centered(Vector2(800, 600))

func _on_select_path_button_pressed() -> void:
	if OS.get_name() == "Android":
		if not _check_storage_permissions():
			_request_storage_permissions()
			return
	
	# Configuração do diálogo para selecionar arquivos ou diretórios
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_ANY
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM
	file_dialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	file_dialog.popup_centered(Vector2(800, 600))

func _on_file_selected(path: String) -> void:
	if path.ends_with(".xml"):
		if _verify_path_access(path):
			Global.save_path = path
			Global.save_save_path()
			select_button.text = path
		else:
			show_error("Não é possível acessar este arquivo.")
	else:
		_on_dir_selected(path)

func _on_dir_selected(dir: String) -> void:
	if _verify_path_access(dir):
		var new_path = dir.path_join("minha_rotina_data.xml")
		Global.save_path = new_path
		Global.save_save_path()
		select_button.text = new_path
		
		# Criar o arquivo XML caso não exista
		if not FileAccess.file_exists(new_path):
			var file = FileAccess.open(new_path, FileAccess.WRITE)
			if file:
				print("Arquivo XML criado:", new_path)
			else:
				show_error("Falha ao criar o arquivo XML.")
		else:
			print("Arquivo XML já existe:", new_path)
	else:
		show_error("Não é possível gravar nesta pasta.")

func _on_file_dialog_canceled():
	pass

func _verify_path_access(path: String) -> bool:
	if OS.get_name() != "Android":
		return true
	
	if path.begins_with(OS.get_user_data_dir()):
		return true
	
	if not _check_storage_permissions():
		return false
	
	if OS.has_feature("android"):
		var dir = DirAccess.open(path.get_base_dir())
		return dir != null
	return true

func show_error(message: String):
	var alert = AcceptDialog.new()
	alert.title = "Erro"
	alert.dialog_text = message
	add_child(alert)
	alert.popup_centered()

# Verificação de permissões para armazenamento no Android
func _check_storage_permissions() -> bool:
	if not OS.has_feature("Android"):
		return true
	
	var permissions = OS.get_granted_permissions()
	return ("android.permission.READ_EXTERNAL_STORAGE" in permissions and 
			"android.permission.WRITE_EXTERNAL_STORAGE" in permissions)

func _request_storage_permissions():
	if OS.has_feature("Android"):
		OS.request_permissions()
