extends Control

enum Shape { OVAL, DIAMOND, SQUIGGLE }
enum CardColor { RED, GREEN, PURPLE }
enum Shading { SOLID, STRIPED, OPEN }

var shape: Shape
var card_color: CardColor
var number: int
var shading: Shading
var is_selected = false
var card_index = -1

signal  card_clicked(card)

func _ready():
	$Panel.gui_input.connect(_on_panel_input)
	update_visual()

func setup(s: Shape, c: CardColor, n: int, sh: Shading, index: int):
	shape = s
	card_color = c
	number = n
	shading = sh
	card_index = index
	if is_inside_tree():
		update_visual()

func _on_panel_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(self)

func set_selected(selected: bool):
	is_selected = selected
	$SelectBorder.visible = selected
	
	if selected:
		$SelectBorder.self_modulate = Color.YELLOW
	else:
		$SelectBorder.self_modulate = Color.WHITE

func update_visual():
	var shape_color: Color
	match card_color:
		CardColor.RED: shape_color = Color.RED
		CardColor.GREEN: shape_color = Color.GREEN
		CardColor.PURPLE: shape_color = Color.PURPLE
	
	var shapes = [$Panel/MarginContainer/VBoxContainer/Shape1, $Panel/MarginContainer/VBoxContainer/Shape2, $Panel/MarginContainer/VBoxContainer/Shape3]
	for i in range(3):
		if i < number:
			shapes[i].visible = true
			shapes[i].color = shape_color
		else:
			shapes[i].visible = false
