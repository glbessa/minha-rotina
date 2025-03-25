extends Node

var counter_correct_pieces = [0, 0, 0, 0]
var counter_missplacement_error = [0, 0, 0, 0]
var total_time = [0, 0, 0, 0]
var click_data = [0, 0, 0, 0]
var interactions_data = [[], [], [], []]

func register_correct_pieces(fase, n):
	counter_correct_pieces[fase] = n
	print("Número de peças corretas armazenado.")

func register_missplacement_error(fase, n):
	counter_missplacement_error[fase] = n
	print("Número de missplacement errors armazenado.")

func register_total_time(fase, n):
	total_time[fase] = n
	print("Tempo gasto na fase armazenado.")

func register_all_clicks(fase, n):
	click_data[fase] = n
	print("Número total de cliques armazenado.")

func register_all_interactions(fase, n):
	interactions_data[fase] = n
	print("Interações armazenadas.")
