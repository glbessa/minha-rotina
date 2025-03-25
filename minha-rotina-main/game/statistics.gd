extends Node

var counter_correct_pieces = [0, 0, 0, 0]
var counter_missplacement_error = [0, 0, 0, 0]
var counter_screen_touches
var counter_interaction_touches
var total_time = [0, 0, 0, 0]

func register_correct_pieces(fase, n):
	counter_correct_pieces[fase] = n
	print("Número de peças corretas armazenado.")

func register_missplacement_error(fase, n):
	counter_missplacement_error[fase] = n
	print("Número de missplacement errors armazenado.")

func register_total_time(fase, n):
	total_time[fase] = n
	print("Tempo gasto na fase armazenado.")
