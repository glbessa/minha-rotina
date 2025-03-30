extends Node

var counter_correct_pieces = [0, 0, 0, 0]
var counter_missplacement_error = [0, 0, 0, 0]
var total_time = [0, 0, 0, 0]
var click_data = [0, 0, 0, 0]
var interactions_data = [[], [], [], []]
var hint1_used = [0, 0, 0, 0]
var hint2_used = [0, 0, 0, 0]
var tempo_medio_entre_acertos = [0.0, 0.0, 0.0, 0.0]
var tempo_medio_entre_erros = [0.0, 0.0, 0.0, 0.0]
var tempo_ate_primeira_interacao = [0.0, 0.0, 0.0, 0.0]
var tempo_medio_clicks = [0.0, 0.0, 0.0, 0.0]
var tempo_medio_interactions = [0.0, 0.0, 0.0, 0.0]
var tempo_ocioso = [0.0, 0.0, 0.0, 0.0] 
var tempo_medio_ocioso = [0.0, 0.0, 0.0, 0.0]  
var maior_sequencia_erros = [0, 0, 0, 0]
var erros_seguidos_atual = [0, 0, 0, 0]


func register_hints(fase, n, m):
	hint1_used[fase] = n
	hint2_used[fase] = m
	print('Usos de dicas 1 e 2 armazenados')

func register_correct_pieces(fase, n):
	counter_correct_pieces[fase] = n
	print("Número de peças corretas armazenado.")

	tempo_medio_entre_acertos[fase] = total_time[fase] / counter_correct_pieces[fase]
	print('Tempo médio entre acertos armazenado.')

func register_missplacement_error(fase, n, acertou):
	counter_missplacement_error[fase] = n
	print("Número de missplacement errors armazenado.")

	# Atualiza tempo médio entre erros
	if counter_missplacement_error[fase] > 0:
		tempo_medio_entre_erros[fase] = total_time[fase] / counter_missplacement_error[fase]
	else:
		tempo_medio_entre_erros[fase] = 0.0

	print('Tempo médio entre erros armazenado.')

	# Atualiza sequência de erros consecutivos
	if acertou:  
		# Se o jogador acertou, verifica se a sequência atual foi a maior e reseta a contagem
		if erros_seguidos_atual[fase] > maior_sequencia_erros[fase]:
			maior_sequencia_erros[fase] = erros_seguidos_atual[fase]
		erros_seguidos_atual[fase] = 0  # Reinicia a contagem de erros consecutivos
	else:
		# Se o jogador errou, aumenta a contagem da sequência de erros
		erros_seguidos_atual[fase] += 1

	# Atualiza a maior sequência de erros se necessário
	if erros_seguidos_atual[fase] > maior_sequencia_erros[fase]:
		maior_sequencia_erros[fase] = erros_seguidos_atual[fase]

	print("Maior sequência de erros registrada:", maior_sequencia_erros[fase])

func register_total_time(fase, n):
	total_time[fase] = n
	print("Tempo gasto na fase armazenado.")

func register_all_clicks(fase, n):
	click_data[fase] = n
	print("Número total de cliques armazenado.")

	tempo_medio_clicks[fase] = total_time[fase] / click_data[fase]
	print('Tempo médio entre cliques armazenado')

func register_all_interactions(fase, n):
	interactions_data[fase] = n
	print("Interações armazenadas.")

	# Tempo até a primeira interação
	tempo_ate_primeira_interacao[fase] = interactions_data[fase][0]
	print('Tempo até primeira interação armazenado.')

	var soma_intervalos = 0.0
	var soma_ocioso = 0.0  # Soma dos intervalos ociosos

	for i in range(1, n.size()):
		var intervalo = n[i] - n[i - 1]
		soma_intervalos += intervalo
		soma_ocioso += intervalo  # Como os intervalos representam tempo sem interação, são "ociosos"

	# Calcula tempo médio entre interações
	if n.size() > 1:
		tempo_medio_interactions[fase] = soma_intervalos / (n.size() - 1)
	else:
		tempo_medio_interactions[fase] = 0.0  # Caso não tenha interações suficientes

	print('Tempo médio entre interações registrado.')

	# Cálculo do tempo ocioso total
	tempo_ocioso[fase] = total_time[fase] - soma_intervalos
	print("Tempo de ociosidade registrado:", tempo_ocioso[fase])

	# Cálculo do tempo médio de ociosidade
	if n.size() > 1:
		tempo_medio_ocioso[fase] = soma_ocioso / (n.size() - 1)
	else:
		tempo_medio_ocioso[fase] = tempo_ocioso[fase]  # Se só tem uma interação, toda a fase foi ociosa

	print("Tempo médio de ociosidade registrado:", tempo_medio_ocioso[fase])
	
func get_next_user_id(xml_content: String) -> int:
	var user_id = 1
	var regex = RegEx.new()
	regex.compile("<usuario id='(\\d+)'>")
	var results = regex.search_all(xml_content)
	
	if results.size() > 0:
		var last_id = int(results[-1].get_string(1))
		user_id = last_id + 1
	
	return user_id

func save_data_to_xml():
	var xml_content = "<?xml version='1.0' encoding='UTF-8'?>\n<game_data>\n"

	# Tenta carregar o XML existente
	var file = FileAccess.open(Global.save_path, FileAccess.READ)
	if file:
		xml_content = file.get_as_text()
		file.close()
		
	if xml_content.strip_edges() == "" or not xml_content.contains("<game_data>"):
		xml_content = "<?xml version='1.0' encoding='UTF-8'?>\n<game_data>\n</game_data>\n"
	# Obtém o próximo ID do usuário
	var user_id = get_next_user_id(xml_content)

	# Obtém a data e hora atual formatada
	var datetime = Time.get_datetime_dict_from_system()
	var formatted_date = "%02d-%02d-%d %02d:%02d:%02d" % [
		datetime.day, datetime.month, datetime.year,
		datetime.hour, datetime.minute, datetime.second
	]

	# Remove a tag de fechamento para adicionar novos dados
	if "</game_data>" in xml_content:
		xml_content = xml_content.replace("</game_data>", "")

	# Adiciona um novo usuário ao XML
	xml_content += "  <usuario id='%d'>\n" % user_id
	xml_content += "      <data>%s</data>\n" % formatted_date

	for i in range(4):  # Supondo que existam 4 fases
		xml_content += "      <fase id='%d'>\n" % (i + 1)
		xml_content += "        <pecas_corretas>%d</pecas_corretas>\n" % counter_correct_pieces[i]
		xml_content += "        <erro_colocacao>%d</erro_colocacao>\n" % counter_missplacement_error[i]
		xml_content += "        <tempo_total>%d</tempo_total>\n" % total_time[i]
		xml_content += "        <cliques>%d</cliques>\n" % click_data[i]
		xml_content += "        <dicas1_usadas>%d</dicas1_usadas>\n" % hint1_used[i]
		xml_content += "        <dicas2_usadas>%d</dicas2_usadas>\n" % hint2_used[i]
		xml_content += "        <tempo_medio_entre_acertos>%.2f</tempo_medio_entre_acertos>\n" % tempo_medio_entre_acertos[i]
		xml_content += "        <tempo_medio_entre_erros>%.2f</tempo_medio_entre_erros>\n" % tempo_medio_entre_erros[i]
		xml_content += "        <tempo_ate_primeira_interacao>%.2f</tempo_ate_primeira_interacao>\n" % tempo_ate_primeira_interacao[i]
		xml_content += "        <tempo_medio_clicks>%.2f</tempo_medio_clicks>\n" % tempo_medio_clicks[i]
		xml_content += "        <tempo_medio_interactions>%.2f</tempo_medio_interactions>\n" % tempo_medio_interactions[i]
		xml_content += "        <tempo_ocioso>%.2f</tempo_ocioso>\n" % tempo_ocioso[i]
		xml_content += "        <tempo_médio_ociosidades>%.2f</tempo_médio_ociosidades>\n" % tempo_medio_ocioso[i]
		xml_content += "        <maior_sequencia_erros>%s</maior_sequencia_erros>\n" % maior_sequencia_erros[i]
		xml_content += "      </fase>\n"

	# **Fechar a tag </usuario> fora do loop**
	xml_content += "  </usuario>\n"
	xml_content += "</game_data>\n"

	# Salva o XML atualizado
	file = FileAccess.open(Global.save_path, FileAccess.WRITE)
	if file:
		file.store_string(xml_content)
		file.close()
		print("Dados salvos com sucesso!")
		print("Arquivo salvo em: ", Global.save_path)
		
func reset_xml():
	var file_path = Global.save_path
	var xml_content = "<?xml version='1.0' encoding='UTF-8'?>\n<game_data>\n</game_data>\n"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(xml_content)
		file.close()
		print("XML resetado com sucesso!")		
