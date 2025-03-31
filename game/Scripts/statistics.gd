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
	xml_content += "\t<usuario id='%d'>\n" % user_id
	xml_content += "\t\t<data>%s</data>\n" % formatted_date
	xml_content += "\t\t<config>\n"
	xml_content += "\t\t\t<musica_ligada>%s</musica_ligada>\n" % ("true" if Global.music_on else "false")
	xml_content += "\t\t\t<musica_volume>%d</musica_volume>\n" % Global.music_volume
	xml_content += "\t\t\t<erros_para_dica_1>%d</erros_para_dica_1>\n" % Global.hint_1_count
	xml_content += "\t\t\t<tempo_de_ociosidade_para_dica_2>%d</tempo_de_ociosidade_para_dica_2>\n" % Global.hint_2_time
	xml_content += "\t\t\t<tempo_memorizacao>%d</tempo_memorizacao>\n" % Global.level_start_duration
	xml_content += "\t\t</config>\n"
	xml_content += "\t\t<fases>\n"
	for i in range(4):  # Supondo que existam 4 fases
		xml_content += "\t\t\t<fase id='%d'>\n" % (i + 1)
		xml_content += "\t\t\t\t<pecas_posicionadas_corretamente>%d</pecas_posicionadas_corretamente>\n" % counter_correct_pieces[i]
		xml_content += "\t\t\t\t<pecas_posicionadas_incorretamente>%d</pecas_posicionadas_incorretamente>\n" % counter_missplacement_error[i]
		xml_content += "\t\t\t\t<tempo_total>%d</tempo_total>\n" % total_time[i]
		xml_content += "\t\t\t\t<cliques>%d</cliques>\n" % click_data[i]
		xml_content += "\t\t\t\t<dicas1_usadas>%d</dicas1_usadas>\n" % hint1_used[i]
		xml_content += "\t\t\t\t<dicas2_usadas>%d</dicas2_usadas>\n" % hint2_used[i]
		xml_content += "\t\t\t\t<tempo_medio_entre_acertos>%.2f</tempo_medio_entre_acertos>\n" % tempo_medio_entre_acertos[i]
		xml_content += "\t\t\t\t<tempo_medio_entre_erros>%.2f</tempo_medio_entre_erros>\n" % tempo_medio_entre_erros[i]
		xml_content += "\t\t\t\t<tempo_ate_primeira_interacao>%.2f</tempo_ate_primeira_interacao>\n" % tempo_ate_primeira_interacao[i]
		xml_content += "\t\t\t\t<tempo_medio_entre_clicks>%.2f</tempo_medio_entre_clicks>\n" % tempo_medio_clicks[i]
		xml_content += "\t\t\t\t<tempo_medio_de_duracao_das_interacoes>%.2f</tempo_medio_de_duracao_das_interacoes>\n" % tempo_medio_interactions[i]
		xml_content += "\t\t\t\t<tempo_ocioso>%.2f</tempo_ocioso>\n" % tempo_ocioso[i]
		xml_content += "\t\t\t\t<tempo_médio_de_ociosidades>%.2f</tempo_médio_de_ociosidades>\n" % tempo_medio_ocioso[i]
		xml_content += "\t\t\t\t<maior_sequencia_erros>%s</maior_sequencia_erros>\n" % maior_sequencia_erros[i]
		xml_content += "\t\t\t</fase>\n"
		
	xml_content += "\t\t</fases>\n"
	xml_content += "\t\t<total_fases>\n"
	
	# Calcular totais
	var total_correct = 0
	var total_incorrect = 0
	var total_time_sum = 0
	var total_clicks = 0
	var total_hint1 = 0
	var total_hint2 = 0
	var avg_between_hits = 0.0
	var avg_between_errors = 0.0
	var avg_first_interaction = 0.0
	var avg_between_clicks = 0.0
	var avg_interaction_duration = 0.0
	var total_idle_time = 0.0
	var avg_idle_time = 0.0
	var max_error_sequence = 0
	
	for i in range(4):
		total_correct += counter_correct_pieces[i]
		total_incorrect += counter_missplacement_error[i]
		total_time_sum += total_time[i]
		total_clicks += click_data[i]
		total_hint1 += hint1_used[i]
		total_hint2 += hint2_used[i]
		avg_between_hits += tempo_medio_entre_acertos[i]
		avg_between_errors += tempo_medio_entre_erros[i]
		avg_first_interaction += tempo_ate_primeira_interacao[i]
		avg_between_clicks += tempo_medio_clicks[i]
		avg_interaction_duration += tempo_medio_interactions[i]
		total_idle_time += tempo_ocioso[i]
		avg_idle_time += tempo_medio_ocioso[i]
		if maior_sequencia_erros[i] > max_error_sequence:
			max_error_sequence = maior_sequencia_erros[i]
	
	xml_content += "\t\t\t<pecas_posicionadas_corretamente>%d</pecas_posicionadas_corretamente>\n" % total_correct
	xml_content += "\t\t\t<pecas_posicionadas_incorretamente>%d</pecas_posicionadas_incorretamente>\n" % total_incorrect
	xml_content += "\t\t\t<tempo_total>%d</tempo_total>\n" % total_time_sum
	xml_content += "\t\t\t<cliques>%d</cliques>\n" % total_clicks
	xml_content += "\t\t\t<dicas1_usadas>%d</dicas1_usadas>\n" % total_hint1
	xml_content += "\t\t\t<dicas2_usadas>%d</dicas2_usadas>\n" % total_hint2
	xml_content += "\t\t\t<tempo_medio_entre_acertos>%.2f</tempo_medio_entre_acertos>\n" % (avg_between_hits / 4.0)
	xml_content += "\t\t\t<tempo_medio_entre_erros>%.2f</tempo_medio_entre_erros>\n" % (avg_between_errors / 4.0)
	xml_content += "\t\t\t<tempo_medio_ate_primeira_interacao>%.2f</tempo_medio_ate_primeira_interacao>\n" % (avg_first_interaction / 4.0)
	xml_content += "\t\t\t<tempo_medio_entre_clicks>%.2f</tempo_medio_entre_clicks>\n" % (avg_between_clicks / 4.0)
	xml_content += "\t\t\t<tempo_medio_de_duracao_das_interacoes>%.2f</tempo_medio_de_duracao_das_interacoes>\n" % (avg_interaction_duration / 4.0)
	xml_content += "\t\t\t<tempo_ocioso>%.2f</tempo_ocioso>\n" % total_idle_time
	xml_content += "\t\t\t<tempo_médio_de_ociosidades>%.2f</tempo_médio_de_ociosidades>\n" % (avg_idle_time / 4.0)
	xml_content += "\t\t\t<maior_sequencia_erros>%s</maior_sequencia_erros>\n" % max_error_sequence
	xml_content += "\t\t</total_fases>\n"

	# **Fechar a tag </usuario> fora do loop**
	xml_content += "\t</usuario>\n"
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
