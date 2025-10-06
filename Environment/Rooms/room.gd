extends Node3D
class_name Room

const WALL_THICKNESS := 0.1
const DOOR_SIZE := Vector2(2, 3)
const DEFAULT_WIDTH := 7.0
const DEFAULT_HEIGHT := 5.0

var room_size := Vector3.ONE

var room_length := 1.0

var left_room : Room
var right_room : Room

func _ready() -> void:
	randomize()
	set_room_size(room_length)
	randomize_wall_textures()


func set_room_size(length:float) -> void:
	room_size = Vector3(length, DEFAULT_HEIGHT, DEFAULT_WIDTH)
	
	$Walls/Floor.size = Vector3(room_size.x, WALL_THICKNESS, room_size.z)
	$Walls/Floor.position = Vector3(room_size.x/2, -WALL_THICKNESS/2, 0)
	
	$Walls/Ceiling.size = Vector3(room_size.x, WALL_THICKNESS, room_size.z)
	$Walls/Ceiling.position = Vector3(room_size.x/2, room_size.y-WALL_THICKNESS/2, 0)
	
	$Walls/Left.size = Vector3(WALL_THICKNESS, room_size.y, room_size.z)
	$Walls/Left.position = Vector3(-WALL_THICKNESS/2, room_size.y/2, 0)
	
	$Walls/Right.size = Vector3(WALL_THICKNESS, room_size.y, room_size.z)
	$Walls/Right.position = Vector3(room_size.x-WALL_THICKNESS/2, room_size.y/2, 0)
	
	$Walls/Back.size = Vector3(room_size.x, room_size.y, WALL_THICKNESS)
	$Walls/Back.position = Vector3(room_size.x/2, room_size.y/2, -room_size.z/2 +WALL_THICKNESS)
	
	$Walls/Front.size = Vector3(room_size.x, room_size.y, WALL_THICKNESS)
	$Walls/Front.position = Vector3(room_size.x/2, room_size.y/2, room_size.z/2 -WALL_THICKNESS)
	
	$RoomLight.position = room_size/2
	$RoomLight.position.z = 0

func get_left_pos() -> float:
	return global_position.x

func get_right_pos() -> float:
	return global_position.x + room_size.x

func get_floor_pos() -> float:
	return global_position.y

func get_ceiling_pos() -> float:
	return global_position.y + room_size.y

func randomize_wall_textures() -> void:
	var texture_index = randi() % 4 + 1
	for wall in [$Walls/Right, $Walls/Left, $Walls/Back]:
		wall.material.albedo_texture = load("res://TestAssets/Textures/wall" + str(texture_index) + "_albedo.png")
		wall.material.normal_texture = load("res://TestAssets/Textures/wall" + str(texture_index) + "_normal.png")
		wall.material.roughness_texture = load("res://TestAssets/Textures/wall" + str(texture_index) + "_roughness.png")
		wall.material.heightmap_texture = load("res://TestAssets/Textures/wall" + str(texture_index) + "_height.png")
