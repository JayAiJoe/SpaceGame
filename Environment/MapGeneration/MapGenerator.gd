extends Node
class_name MapGraphGenerator

# -------------------
# Tunable parameters
# -------------------
@export var grid_width := 5
@export var grid_height := 5
@export var total_rooms := 12
@export var vertical_weight := 0.3    # Base chance for vertical growth
@export var vertical_bonus := 0.5      # Bonus if parent cell already has vertical connection

# -------------------
# Internal
# -------------------
var _id_counter := 0

func generate() -> Dictionary:
	_id_counter = 0
	var graph := {}
	var grid := []
	for y in range(grid_height):
		grid.append([])
		for i in range(grid_width):
			grid[y].append(null)

	# --- Step 1: pick root ---
	var root_x = randi() % grid_width
	var root_y = randi() % grid_height
	var root = _make_room(Vector2i(root_x, root_y))
	graph[root.id] = root
	grid[root_y][root_x] = root
	var active := [root]
	var rooms_created := 1

	# --- Step 2: growth loop ---
	while rooms_created < total_rooms and active.size() > 0:
		var next_active := []
		for room in active:
			var dirs := [Vector2i(0, -1), Vector2i(0, 1), Vector2i(-1, 0), Vector2i(1, 0)]
			dirs.shuffle()
			for d in dirs:
				var nx = room.pos.x + d.x
				var ny = room.pos.y + d.y
				if nx < 0 or nx >= grid_width or ny < 0 or ny >= grid_height:
					continue
				if grid[ny][nx] != null:
					continue
				# Determine vertical weight
				var w = 1.0
				if d.y != 0:
					w = vertical_weight
					if (d.y < 0 and room.up != null) or (d.y > 0 and room.down != null):
						w = vertical_weight + vertical_bonus
				if randf() <= w:
					var new_room = _make_room(Vector2i(nx, ny))
					graph[new_room.id] = new_room
					grid[ny][nx] = new_room
					_link_directional(room, new_room)
					next_active.append(new_room)
					rooms_created += 1
					if rooms_created >= total_rooms:
						break
			if rooms_created >= total_rooms:
				break
		active = next_active

	# --- Step 3: assign vertical chains (stairs/elevators) ---
	var memo := {}
	for room in graph.values():
		if room.kind != null:
			continue
		if room.up != null: 
			continue  # only process the top of each vertical chain

		# Count the vertical chain starting from this top room
		var height = _calculate_vertical_height(room, memo)
		if height == 2:
			_assign_vertical_chain_fixed(room, "stairs", height)
		elif height >= 3:
			_assign_vertical_chain_fixed(room, "elevator", height)


	# --- Step 4: assign horizontal kinds ---
	for room in graph.values():
		if room.kind != null:
			continue
		var horizontal = 0
		if room.left != null:
			horizontal += 1
		if room.right != null:
			horizontal += 1
		if horizontal == 2:
			room.kind = "lab"
		else:
			room.kind = "storage"

	return graph

# -------------------
# Utilities
# -------------------
func _make_room(pos: Vector2i) -> Dictionary:
	var id = str(_id_counter)
	_id_counter += 1
	return {
		"id": id,
		"pos": pos,
		"kind": null,
		"left": null,
		"right": null,
		"up": null,
		"down": null
	}

func _link_directional(a, b):
	if a.pos.x == b.pos.x:
		if a.pos.y < b.pos.y:
			a.down = b
			b.up = a
		else:
			a.up = b
			b.down = a
	elif a.pos.y == b.pos.y:
		if a.pos.x < b.pos.x:
			a.right = b
			b.left = a
		else:
			a.left = b
			b.right = a

# Recursively count actual vertical chain
func _calculate_vertical_height(room, cache) -> int:
	if cache.has(room.id):
		return cache[room.id]
	var count = 1
	if room.down != null:
		count += _calculate_vertical_height(room.down, cache)
	cache[room.id] = count
	return count

# Assign kind to entire vertical chain
func _assign_vertical_chain(room, kind):
	if room == null or room.kind == kind:
		return
	room.kind = kind
	if room.down != null:
		_assign_vertical_chain(room.down, kind)
	if room.up != null:
		_assign_vertical_chain(room.up, kind)

# Fixed assignment: only assign along the exact chain
func _assign_vertical_chain_fixed(room, kind, remaining_height):
	var current = room
	for i in range(remaining_height):
		current.kind = kind
		current = current.down
		if current == null:
			break
