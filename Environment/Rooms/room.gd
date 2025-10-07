extends Node3D
class_name Room

const WALL_THICKNESS := 0.1
const DOOR_SIZE := Vector2(2, 3)
const DEFAULT_WIDTH := 7.0
const DEFAULT_HEIGHT := 5.0
const ROOM_SIZE_GRANULARITY : int = 5

var room_size := Vector3.ONE

var room_length : int = 5
var room_height : int = 5

var left_room : Room
var right_room : Room

@onready var camera = $RoomCameraAnchor/Camera3D
@onready var room_area: CollisionShape3D = $RoomArea/CollisionShape3D

func _ready() -> void:
	randomize()
	set_room_size(room_length, room_height)
	randomize_wall_textures()
	set_room_info(room_length)
	Events.player_entered_room.connect(_on_player_entered_room)
	
	
func set_room_info(length : int) -> void:
	room_length = length
	set_room_size(length)
	adjust_camera_to_room(length)
	
	$Items/Button.position = Vector3(room_size.x/2.0, 0, -room_size.z/2.0 + 0.5)
	$Items/Gun.position = Vector3(room_size.x/2.0, 0, 0)
	


func set_room_size(length:float, height:=DEFAULT_HEIGHT) -> void:
	room_size = Vector3(length, height, DEFAULT_WIDTH)
	
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
	
	# Room Area
	if room_area and room_area.shape is BoxShape3D:
		var box: BoxShape3D = room_area.shape
		# Inner space: subtract wall thickness on all sides
		var inner_size = Vector3(
			room_size.x - WALL_THICKNESS * 2.0,
			room_size.y - WALL_THICKNESS * 2.0,
			room_size.z - WALL_THICKNESS * 2.0
		)
		box.extents = inner_size / 2.0
		# Center between the inner faces of walls
		$RoomArea.position = Vector3(
			WALL_THICKNESS + inner_size.x / 2.0,
			WALL_THICKNESS + inner_size.y / 2.0,
			0
		)
	
	# Add this:
	var inner_length = length - WALL_THICKNESS * 2
	var inner_width = DEFAULT_WIDTH - WALL_THICKNESS * 2
	var inner_height = DEFAULT_HEIGHT - WALL_THICKNESS

	var area = $RoomArea
	var shape = area.get_node("CollisionShape3D").shape as BoxShape3D
	shape.size = Vector3(inner_length, inner_height, inner_width)
	
	# Offset the Area3D so its center matches the inner volume, not outer volume
	area.position = Vector3(length / 2, inner_height / 2, 0)

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

func _on_player_entered_room(player, room) -> void:
	if room == self:
		camera.current = true
		$Walls/Front.visible = false
	else:
		$Walls/Front.visible = true
	

func _on_room_area_area_entered(area):
	if area.owner.is_in_group("Players"):
		Events.player_entered_room.emit(area.owner, self)
		#set_as_player_current_room()

func adjust_camera_to_room2(rlength: float):
	var fov_rad := deg_to_rad(camera.fov) # usually 75 degrees
	var half_width := rlength / 2.0
	
	# Calculate required z distance
	var distance := half_width / tan(fov_rad / 2.0)
	
	# Move camera to center of the room and back by calculated distance
	camera.position.x = half_width
	camera.position.z = distance
	
	# Optional: add some vertical offset if your camera looks slightly downward
	camera.position.y = DEFAULT_HEIGHT / 2.0
	
	# Optional: add small margin so walls aren't cut off
	var margin := 1.1
	camera.position.z *= margin

func adjust_camera_to_room(rlength: float):
	var half_width := rlength / 2.0
	var margin := 1.1

	# --- Nonlinear approximation instead of strict FOV math ---
	# These values can be tuned to your liking
	var base_dist := 4.0        # baseline distance for small rooms
	var scale_var := 0.6            # how quickly distance grows with room width

	# use sqrt curve to make wide rooms zoom out less aggressively
	var distance := base_dist + sqrt(half_width) * scale_var

	# Apply margin so walls aren't cut off
	distance *= margin

	# --- Apply to camera ---
	camera.position.x = half_width
	camera.position.z = distance
	camera.position.y = DEFAULT_HEIGHT / 2.0 + 1.0

	# Make sure the camera looks toward the center of the room
	# TEMP: const -9.7 x
	#camera.look_at(Vector3(half_width, DEFAULT_HEIGHT / 2.0, 0))
