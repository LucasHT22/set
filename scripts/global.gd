extends Node

var num_players = 1
var player_scores = {}

func reset_scores():
	player_scores.clear()
	for i in range(num_players):
		player_scores[i + 1] = 0
