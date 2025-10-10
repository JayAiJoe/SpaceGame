extends Room

func set_room_size(length:float, height:=DEFAULT_HEIGHT) -> void:
	super(length, height)
	var num_floors = height/DEFAULT_HEIGHT
	$Walls/Left/Doorway.hide()
	var right_doorway = $Walls/Right/Doorway2
	right_doorway.global_position.y = right_doorway.size.y/2
	for floor_height in range(1, num_floors):
		var new_doorway = right_doorway.duplicate()
		$Walls/Right.add_child(new_doorway)
		new_doorway.global_position.y = right_doorway.size.y/2 + floor_height * DEFAULT_HEIGHT
	
