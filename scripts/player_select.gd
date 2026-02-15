extends Control

func _ready():
	$CenterContainer/VBoxContainer/ButtonContainer/Player1Btn.pressed.connect(func(): start_game(1))
	$CenterContainer/VBoxContainer/ButtonContainer/Player2Btn.pressed.connect(func(): start_game(2))
	$CenterContainer/VBoxContainer/ButtonContainer/Player3Btn.pressed.connect(func(): start_game(3))
	$CenterContainer/VBoxContainer/ButtonContainer/Player4Btn.pressed.connect(func(): start_game(4))

func start_game(num_players: int):
	Global.num_players = num_players
	Global.reset_scores()
	get_tree().change_scene_to_file("res://scenes/main_game.tscn")
