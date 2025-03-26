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

func register_hints(fase, n, m):
	hint1_used[fase] = n
	hint2_used[fase] = m
	print('Usos de dicas 1 e 2 armazenados')

func register_correct_pieces(fase, n):
	counter_correct_pieces[fase] = n
	print("Número de peças corretas armazenado.")

	tempo_medio_entre_acertos[fase] = total_time[fase] / counter_correct_pieces[fase]
	print('Tempo médio entre acertos armazenado.')

func register_missplacement_error(fase, n):
	counter_missplacement_error[fase] = n
	print("Número de missplacement errors armazenado.")

	tempo_medio_entre_erros[fase] = total_time[fase] / counter_missplacement_error[fase]
	print('Tempo médio entre erros armazenado.')

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

	tempo_ate_primeira_interacao[fase] = interactions_data[fase][0]
	print('Tempo até primeira interação armazenado.')

	var soma_intervalos = 0.0
	for i in range(1, n.size()):
		soma_intervalos += n[i] - n[i - 1]
	tempo_medio_interactions[fase] = soma_intervalos / (n.size() - 1)
	print('Tempo médio entre interações registrado.')
