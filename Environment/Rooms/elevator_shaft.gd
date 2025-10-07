extends Room

func _ready() -> void:
	randomize()
	set_room_size(room_length, room_height)
	randomize_wall_textures()
