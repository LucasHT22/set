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
	$Panel/MarginContainer/ShapeContainer.queue_redraw()

func _draw():
	pass

class ShapeDrawer extends Control:
	var parent_card: Control
	
	func _ready():
		parent_card = get_parent().get_parent().get_parent()
	
	func _draw():
		if not parent_card:
			return
		
		var shape_color: Color
		match parent_card.card_color:
			parent_card.CardColor.RED: shape_color = Color.RED
			parent_card.CardColor.GREEN: shape_color = Color.GREEN
			parent_card.CardColor.PURPLE: shape_color = Color.PURPLE
		
		var container_size = size
		var shape_width = 60
		var shape_height = 30
		var spacing = 10
		
		for i in range(parent_card.number):
			var y_offset = (container_size.y - (parent_card.number * shape_height + (parent_card.number - 1) * spacing))
			var y_pos = y_offset + i * (shape_height + spacing)
			var x_pos = (container_size.x - shape_width) / 2
			
			var position = Vector2(x_pos, y_pos)
			draw_single_shape(position, shape_width, shape_height, parent_card.shape, shape_color, parent_card.shading)
	
	func draw_single_shape(pos: Vector2, width: float, height: float, color: Color, shading_type):
		match shape_type:
			0:
				draw_oval(pos, width, height, color, shading_type)
			1:
				draw_diamond(pos, width, height, color, shading_type)
			2:
				draw_squiggle(pos, width, height, color, shading_type)
	
	func draw_oval(pos: Vector2, width: float, height: float, color: Color, shading_type):
		var center = pos + Vector2(width / 2, height / 2)
		var radius_x = width / 2
		var radius_y = height / 2
		
		var points = PackedVector2Array()
		var num_points = 32
		for i in range(num_points):
			var angle = (i * TAU) / num_points
			var x = center.x + cos(angle) * radius_x
			var y = center.y + sin(angle) * radius_y
			points.append(Vector2(x, y))
		
		match shading_type:
			0:
				draw_colored_polygon(points, color)
			1:
				draw_colored_polygon(points, Color.WHITE)
				draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
				draw_stripes_in_shape(pos, width, height, color, points)
			2:
				draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
	
	func draw_diamond(pos: Vector2, width: float, height: float, color: Color, shading_type):
		var center = pos + Vector2(width / 2, height / 2)
		
		var points = PackedVector2Array([
			center + Vector2(0, -height / 2),
			center + Vector2(width / 2, 0),
			center + Vector2(0, height / 2),
			center + Vector2(-width / 2, 0)
		])
		
		match shading_type:
			0:
				draw_colored_polygon(points, color)
			1:
				draw_colored_polygon(points, Color.WHITE)
				draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
				draw_stripes_in_shape(pos, width, height, color, points)
			2:
				draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
	
	func draw_squiggle(pos: Vector2, width: float, height: float, color: Color, shading_type):
		var p1 = pos + Vector2(width * 0.2, height * 0.8)
		var p2 = pos + Vector2(width * 0.8, height * 0.2)
		var ctrl1 = pos + Vector2(width * 0.1, height * 0.2)
		var ctrl2 = pos + Vector2(width * 0.9, height * 0.8)
		
		var points = PackedVector2Array()
		var steps = 20
		for i in range(steps + 1):
			var t = float(i) / steps
			var point = bezier_point(p1, ctrl1, ctrl2, p2, t)
			points.append(point)
		
		for i in range(steps + 1):
			var t = float(i) / steps
			var points = bezier_point(p2, ctrl2 + Vector2(0, 10), ctrl1 + Vector2(0, 10), p1, t)
			points.append(point)
		
		match shading_type:
			0:
				draw_colored_polygon(points, color)
			1:
				draw_colored_polygon(points, Color.WHITE)
				draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
				draw_stripes_in_shape(pos, width, height, color, points)
			2:
				draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
	
	func draw_stripes_in_shape(pos: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
		var stripe_spacing = 4
		for x in range(int(pos.x), int(pos.x + width), stripe_spacing):
			var start = Vector2(x, pos.y)
			var end = Vector2(x, pos.y + height)
			draw_line(start, end, color, 1.0)
	
	func bezier_point(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
		var u = 1.0 - t
		var tt = t * t
		var uu = u * u
		var uuu = uu * u
		var ttt = tt * t
		
		var p = uuu * p0
		p += 3 * uu * t * p1
		p += 3 * u * tt * p2
		p += ttt * p3
		
		return p
