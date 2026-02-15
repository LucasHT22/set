extends Control

var card_scene = preload("res://scenes/card.tscn")
var deck = []
var table_cards = []
var selected_cards = []
var claiming_player = -1
var is_claiming = false

func _ready():
	var claim_buttons = [
		$MarginContainer/VBoxContainer/ClaimButtons/Player1Claim,
		$MarginContainer/VBoxContainer/ClaimButtons/Player2Claim,
		$MarginContainer/VBoxContainer/ClaimButtons/Player3Claim,
		$MarginContainer/VBoxContainer/ClaimButtons/Player4Claim
	]
	
	for i in range(4):
		if i < Global.num_players:
			claim_buttons[i].visible = true
			var colors = [Color.ROYAL_BLUE, Color.CRIMSON, Color.DARK_GREEN, Color.DARK_ORANGE]
			claim_buttons[i].modulate = colors[i]
			
			var player_num = i + 1
			claim_buttons[i].pressed.connect(func(): player_claims_set(player_num))
		else:
			claim_buttons[i].visible = false
	
	var score_labels = [
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player1Score,
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player2Score,
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player3Score,
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player4Score
	]
	
	for i in range(4):
		score_labels[i].visible = (i < Global.num_players)
	
	$MarginContainer/VBoxContainer/SelectionUI.visible = false
	$MarginContainer/VBoxContainer/SelectionUI/ButtonsRow/ConfirmButton.pressed.connect(confirm_set)
	$MarginContainer/VBoxContainer/SelectionUI/ButtonsRow/CancelButton.pressed.connect(cancel_claim)
	$NewGameButton.pressed.connect(new_game)
	
	create_deck()
	deal_initial_cards()
	update_scores()

func create_deck():
	for shape in 3:
		for card_color in 3:
			for number in range(1, 4):
				for shading in 3:
					deck.append({
						"shape": shape,
						"card_color": card_color,
						"number": number,
						"shading": shading
					})
	deck.shuffle()

func deal_initial_cards():
	for i in range(12):
		add_card_to_table(i)

func add_card_to_table(index: int):
	if deck.is_empty():
		return
	
	var card_data = deck.pop_front()
	var card = card_scene.instantiate()
	$MarginContainer/VBoxContainer/CenterContainer/CardGrid.add_child(card)
	card.setup(card_data.shape, card_data.card_color, card_data.number, card_data.shading, index)
	card.card_clicked.connect(_on_card_clicked)
	table_cards.append(card)

func _on_card_clicked(card):
	if not is_claiming:
		return

	if card.is_selected:
		card.set_selected(false)
		selected_cards.erase(card)
	else:
		if selected_cards.size() < 3:
			card.set_selected(true)
			selected_cards.append(card)
		
	$MarginContainer/VBoxContainer/SelectionUI/InstructionLabel.text = "Player %d: Select 3 cards (%d/3 selected)" % [claiming_player, selected_cards.size()]

func player_claims_set(player_num: int):
	claiming_player = player_num
	is_claiming = true
	for button in $MarginContainer/VBoxContainer/ClaimButtons.get_children():
		if button.visible:
			button.disabled = true
	
	$MarginContainer/VBoxContainer/SelectionUI.visible = true
	$MarginContainer/VBoxContainer/SelectionUI/InstructionLabel.text = "Player %d: Click 3 cards to make your SET (0/3 selected)" % player_num
	$MarginContainer/VBoxContainer/TopUI/MessageLabel.text = "Player %d is selecting cards..." % player_num
	$MarginContainer/VBoxContainer/TopUI/MessageLabel.modulate = Color.YELLOW

func confirm_set():
	if selected_cards.size() != 3:
		$MarginContainer/VBoxContainer/TopUI/MessageLabel.text = "⚠ You must select exactly 3 cards!"
		$MarginContainer/VBoxContainer/TopUI/MessageLabel.modulate = Color.ORANGE
		return
	
	var c1 = selected_cards[0]
	var c2 = selected_cards[1]
	var c3 = selected_cards[2]
	
	var is_valid = (
		check_atribute(c1.shape, c2.shape, c3.shape) and 
		check_atribute(c1.card_color, c2.card_color, c3.card_color) and 
		check_atribute(c1.number, c2.number, c3.number) and 
		check_atribute(c1.shading, c2.shading, c3.shading)
	)
	
	if is_valid:
		Global.player_scores[claiming_player] += 1
		$MarginContainer/VBoxContainer/TopUI/MessageLabel.text = "✓ Player %d found a SET! +1 point" % claiming_player
		$MarginContainer/VBoxContainer/TopUI/MessageLabel.modulate = Color.GREEN
		
		for card in selected_cards:
			card.modulate = Color.GREEN
		
		await  get_tree().create_timer(1.0).timeout
		
		for card in selected_cards:
			table_cards.erase(card)
			card.queue_free()
		
		for i in range(3):
			add_card_to_table(table_cards.size())
	
	else:
		Global.player_scores[claiming_player] -= 1
		$MarginContainer/VBoxContainer/TopUI/MessageLabel.text = "✗ Player %d - NOT a SET! -1 point penalty" % claiming_player
		$MarginContainer/VBoxContainer/TopUI/MessageLabel.modulate = Color.RED
		
		for card in selected_cards:
			card.modulate = Color.RED
		
		await get_tree().create_timer(1.0).timeout
		
		for card in selected_cards:
			card.modulate = Color.WHITE
			card.set_selected(false)
	
	update_scores()
	await get_tree().create_timer(1.5).timeout
	reset_claim_state()

func cancel_claim():
	for card in selected_cards:
		card.set_selected(false)
	
	$MarginContainer/VBoxContainer/TopUI/MessageLabel.text = "Player %d cancelled their claim" % claiming_player
	$MarginContainer/VBoxContainer/TopUI/MessageLabel.modulate = Color.GRAY
	
	await get_tree().create_timer(1.0).timeout
	
	reset_claim_state()

func reset_claim_state():
	is_claiming = false
	claiming_player = -1
	selected_cards.clear()
	$MarginContainer/VBoxContainer/SelectionUI.visible = false
	
	for button in $MarginContainer/VBoxContainer/ClaimButtons.get_children():
		if button.visible:
			button.disabled = false
	
	$MarginContainer/VBoxContainer/TopUI/MessageLabel.text = "Click your button when you see a SET!"
	$MarginContainer/VBoxContainer/TopUI/MessageLabel.modulate = Color.WHITE

func check_atribute(a1, a2, a3) -> bool:
	return (a1 == a2 and a2 == a3) or (a1 != a2 and a2 != a3 and a1 != a3)

func update_scores():
	var labels = [
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player1Score,
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player2Score,
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player3Score,
		$MarginContainer/VBoxContainer/TopUI/ScoresContainer/Player4Score
	]
	
	for i in range(Global.num_players):
		var score = Global.player_scores[i + 1]
		labels[i].text = "Player %d: %d pts" % [i + 1, score]

func new_game():
	get_tree().change_scene_to_file("res://scenes/player_select.tscn")
