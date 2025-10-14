extends Node2D
class_name MapGraphVisualizer2D

@export var generator = MapGraphGenerator.new()
@export var side_length := 50
@export var connector_length := 15
@export var zoom := 1.0
@export var pan := Vector2.ZERO
@export var font: Font  # assign a font in the Inspector

var graph := {}
var visited := {}
var room_positions := {}  # room.id -> Vector2 grid pos
var room_count := 0

func _ready():
	refresh()

func refresh():
	graph = generator.generate()
	visited.clear()
	room_positions.clear()
	room_count = 0

	if graph.size() > 0:
		var start_room = graph.values()[0]
		_place_room_recursive(start_room, Vector2i(0, 0))

	print("Rooms placed: ", room_count, "\tRooms in graph: ", graph.size(), "\tDifference: ", abs(graph.size()-room_count))
	queue_redraw()

func _place_room_recursive(room, grid_pos: Vector2i):
	if visited.has(room.id):
		return
	visited[room.id] = true
	room_positions[room.id] = grid_pos
	room_count += 1

	for dir_name in ["up", "down", "left", "right"]:
		if not room.has(dir_name):
			continue
		var neighbor = room[dir_name]
		if neighbor == null:
			continue
		if visited.has(neighbor.id):
			continue

		var offset = Vector2i.ZERO
		match dir_name:
			"up":
				offset = Vector2i(0, -1)
			"down":
				offset = Vector2i(0, 1)
			"left":
				offset = Vector2i(-1, 0)
			"right":
				offset = Vector2i(1, 0)
		_place_room_recursive(neighbor, grid_pos + offset)

func _room_screen_pos(grid_pos: Vector2i) -> Vector2:
	return Vector2(
		grid_pos.x * (side_length + connector_length) * zoom + pan.x,
		grid_pos.y * (side_length + connector_length) * zoom + pan.y
	)

func _draw():
	if graph.size() == 0:
		return

	# draw connectors
	for room in graph.values():
		if not room_positions.has(room.id):
			continue
		var pos_a = _room_screen_pos(room_positions[room.id]) + Vector2(side_length/2, side_length/2) * zoom
		for dir_name in ["up", "down", "left", "right"]:
			if not room.has(dir_name):
				continue
			var neighbor = room[dir_name]
			if neighbor == null:
				continue
			if not room_positions.has(neighbor.id):
				continue
			var neighbor_pos = _room_screen_pos(room_positions[neighbor.id]) + Vector2(side_length/2, side_length/2) * zoom
			if room.id.to_int() < neighbor.id.to_int(): # avoid double lines
				draw_line(pos_a, neighbor_pos, Color(0.8,0.8,0.8), 3)

	# draw rooms
	for room in graph.values():
		if not room_positions.has(room.id):
			continue
		var pos = _room_screen_pos(room_positions[room.id])
		var color = Color(0.4, 0.7, 1.0) # default room
		if room.has("kind"):
			match room.kind:
				"stairs":
					color = Color(1.0, 0.9, 0.3)
				"elevator":
					color = Color(1.0, 0.5, 0.1)
				"lab":
					color = Color(0.4, 0.7, 1.0)
				"storage":
					color = Color(0.7, 0.7, 0.7)
		draw_rect(Rect2(pos, Vector2(side_length, side_length) * zoom), color, true)
		draw_rect(Rect2(pos, Vector2(side_length, side_length) * zoom), Color.BLACK, false, 2)

		# draw kind text
		if room.has("kind") and font != null:
			#draw_set_color(Color.BLACK)
			draw_string(font, pos + Vector2(5, side_length/2), room.kind)
			#draw_set_color(Color(1,1,1)) # reset

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom *= 1.1
			queue_redraw()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom /= 1.1
			queue_redraw()
	elif event is InputEventMouseMotion:
		if event.button_mask & MOUSE_BUTTON_MASK_MIDDLE:
			pan += event.relative
			queue_redraw()
	elif event.is_action_pressed("ui_accept"):
		refresh()
