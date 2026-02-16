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

signal card_clicked(card)

func _ready():
	$Panel.gui_input.connect(_on_panel_input)
	update_visual()

func setup(s: Shape, c: CardColor, n: int, sh: Shading, index: int):
	shape = s
	card_color = c
	number = n
	shading = sh
	card_index = index
	
	$Panel/MarginContainer/ShapeContainer.queue_redraw()
	
	print("Card setup: shape=", shape, " color=", card_color, " number=", number, " shading=", shading)

func _on_panel_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		card_clicked.emit(self)

func set_selected(selected: bool):
	is_selected = selected
	$SelectBorder.visible = selected
	
	if selected:
		$SelectBorder.self_modulate = Color.YELLOW
	else:
		$SelectBorder.self_modudlate = Color.WHITE

func update_visual():
	$Panel/MarginContainer/ShapeContainer.queue_redraw()

func get_card_properties():
	return {
		"shape": shape,
		"card_color": card_color,
		"number": number,
		"shading": shading
	}
