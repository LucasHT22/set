extends Control

func _draw():
	var card = get_parent().get_parent().get_parent()
	
	var props = card.get_card_properties()
	
	var shape_color = get_shape_color(props.card_color)
	
	var shape_width = 60
	var shape_height = 30
	var spacing = 10
	
	for i in range(props.number):
		var y_offset = (size.y - (props.number * shape_height + (props.number - 1) * spacing)) / 2
		var y_pos = y_offset + i * (shape_height + spacing)
		var x_pos = (size.x - shape_width) / 2
		
		draw_shape_at(Vector2(x_pos, y_pos), shape_width, shape_height, props.shape, shape_color, props.shading)

func get_shape_color(card_color_enum):
	match card_color_enum:
		0: return Color.RED
		1: return Color.GREEN
		2: return Color.PURPLE
	return Color.WHITE

func draw_shape_at(pos: Vector2, width: float, height: float, shape_type, color: Color, shading_type):
	var rect = Rect2(pos, Vector2(width, height))
	
	match shape_type:
		0:
			draw_oval_shape(rect, color, shading_type)
		1:
			draw_diamond_shape(rect, color, shading_type)
		2:
			draw_squiggle_shape(rect, color, shading_type)

func draw_oval_shape(rect: Rect2, color: Color, shading_type):
	var center = rect.position + rect.size / 2
	var radius_x = rect.size.x / 2
	var radius_y = rect.size.y / 2
	
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
			for x in range(int(rect.position.x), int(rect.position.x + rect.size.x), 4):
				draw_line(Vector2(x, rect.position.y), Vector2(x, rect.position.y + rect.size.y), color, 1.0)
			draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
		2:
			draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)

func draw_diamond_shape(rect: Rect2, color: Color, shading_type):
	var center = rect.position + rect.size / 2
	var points = PackedVector2Array([
		center + Vector2(0, -rect.size.y / 2),
		center + Vector2(rect.size.x / 2, 0),
		center + Vector2(0, rect.size.y / 2),
		center + Vector2(-rect.size.x / 2, 0)
	])
	
	match shading_type:
		0:
			draw_colored_polygon(points, color)
		1:
			draw_colored_polygon(points, Color.WHITE)
			for x in range(int(rect.position.x), int(rect.position.x + rect.size.x), 4):
				draw_line(Vector2(x, rect.position.y), Vector2(x, rect.position.y + rect.size.y), color, 1.0)
			draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
		2:
			draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)

func draw_squiggle_shape(rect: Rect2, color: Color, shading_type):
	var points = PackedVector2Array()
	
	var left_x = rect.position.x
	var right_x = rect.position.x + rect.size.x
	var top_y = rect.position.y
	var bottom_y = rect.position.y + rect.size.y
	var mid_y = rect.position.y + rect.size.y / 2
	
	var p0 = Vector2(left_x + rect.size.x * 0.2, top_y + rect.size.y * 0.3)
	var p1 = Vector2(left_x + rect.size.x * 0.4, top_y)
	var p2 = Vector2(right_x - rect.size.x * 0.4, top_y)
	var p3 = Vector2(right_x - rect.size.x * 0.2, top_y + rect.size.y * 0.3)
	
	var steps = 20
	for i in range(steps + 1):
		var t = float(i) / steps
		points.append(bezier_cubic(p0, p1, p2, p3, t))
	
	var r0 = p3
	var r1 = Vector2(right_x, mid_y - rect.size.y * 0.1)
	var r2 = Vector2(right_x, mid_y + rect.size.y * 0.1)
	var r3 = Vector2(right_x - rect.size.x * 0.2, bottom_y - rect.size.y * 0.3)
	
	for i in range(1, steps + 1):
		var t = float(i) / steps
		points.append(bezier_cubic(r0, r1, r2, r3, t))
	
	var b0 = r3
	var b1 = Vector2(right_x - rect.size.x * 0.4, bottom_y)
	var b2 = Vector2(left_x + rect.size.x * 0.4, bottom_y)
	var b3 = Vector2(left_x + rect.size.x * 0.2, bottom_y - rect.size.y * 0.3)
	
	for i in range(1, steps + 1):
		var t = float(i) / steps
		points.append(bezier_cubic(b0, b1, b2, b3, t))
	
	var l0 = b3
	var l1 = Vector2(left_x, mid_y + rect.size.y * 0.1)
	var l2 = Vector2(left_x, mid_y - rect.size.y * 0.1)
	var l3 = p0
	
	for i in range(1, steps):
		var t = float(i) / steps
		points.append(bezier_cubic(l0, l1, l2, l3, t))
	
	match shading_type:
		0:
			draw_colored_polygon(points, color)
		1:
			draw_colored_polygon(points, Color.WHITE)
			for x in range(int(rect.position.x), int(rect.position.x + rect.size.x), 4):
				draw_line(Vector2(x, rect.position.y), Vector2(x, rect.position.y + rect.size.y), color, 1.5)
			draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)
		2:
			draw_polyline(points + PackedVector2Array([points[0]]), color, 2.0)

func bezier_cubic(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	
	var point = uuu * p0
	point += 3 * uu * t * p1
	point += 3 * u * tt * p2
	point += ttt * p3
	
	return point
