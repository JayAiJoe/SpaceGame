extends Node3D

const ROOM = preload("res://Environment/Rooms/room.tscn")

var first_rooms := [] # array of doubly linked lists

const FLOORS_NUM := 5

func _ready() -> void:
	create_floors()

func create_floors() -> void:
	var max_width := 30.
	var downstairs_room : Room = null
	for i in range(FLOORS_NUM):
		var new_floor_start = create_floor(max_width, 3)
		first_rooms.append(new_floor_start)
		if downstairs_room:
			var room = new_floor_start
			var new_floor_height = downstairs_room.get_ceiling_pos()
			while room:
				room.global_position.y = new_floor_height
				room = room.right_room
				
		downstairs_room = first_rooms[i]

func create_floor(total_length:float, rooms:int) -> Room:
	var first_room : Room
	var left_room : Room = null
	var current_length := 0.0
	for i in range(rooms):
		var room_length : float
		if i < rooms-1:
			room_length = (total_length - current_length)/(rooms - i) * randf_range(0.65, 1.35)
			current_length += room_length
		else:
			room_length = total_length - current_length
			
		var new_room = ROOM.instantiate()
		new_room.room_length = room_length
		add_child(new_room)
		
		if left_room:
			left_room.right_room = new_room
			new_room.left_room = left_room
			
			new_room.global_position.x = left_room.get_right_pos()
			
		else: # first_room
			first_room = new_room
			
		left_room = new_room
	
	return first_room
