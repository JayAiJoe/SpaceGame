extends Node3D
class_name MapLoader3D

const ROOM_SCENE := preload("res://Environment/Rooms/room.tscn")

# Room spacing matches default Room dimensions
const ROOM_DEPTH := 5.0  # unused now but could be useful for Z offsets

@onready var generator := MapGraphGenerator.new()

var instantiated_rooms := {} # room.id -> Room instance

func _ready() -> void:
	load_map()

func load_map() -> void:
	instantiated_rooms.clear()
	var graph = generator.generate()

	if graph.size() == 0:
		return
	var visited := {}
	var start_room = graph.values()[0]
	_place_room_recursive(start_room, Vector3.ZERO, visited)

func _place_room_recursive(room_data: Dictionary, world_pos: Vector3, visited: Dictionary) -> void:
	if visited.has(room_data.id):
		return
	visited[room_data.id] = true

	# --- instantiate room scene ---
	var room_instance: Room = ROOM_SCENE.instantiate()
	add_child(room_instance)
	room_instance.global_position = world_pos
	room_instance.set_room_info(room_data) # set length to match default width
	instantiated_rooms[room_data.id] = room_instance
	


	# --- place neighbors recursively ---
	var neighbor_dirs = {
		"left": Vector3(-Room.DEFAULT_WIDTH, 0, 0),
		"right": Vector3(Room.DEFAULT_WIDTH, 0, 0),
		"up": Vector3(0, Room.DEFAULT_HEIGHT, 0),
		"down": Vector3(0, -Room.DEFAULT_HEIGHT, 0)
	}

	for dir_name in ["left", "right", "up", "down"]:
		var neighbor = room_data.get(dir_name, null)
		if neighbor != null and not visited.has(neighbor.id):
			var neighbor_pos = world_pos + neighbor_dirs[dir_name]
			_place_room_recursive(neighbor, neighbor_pos, visited)
