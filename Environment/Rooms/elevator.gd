extends Room

const CAR_SPEED := 7.53
var doorways := {}
var floors : int
var car_tween : Tween

func set_room_size(length:float, height:=DEFAULT_HEIGHT) -> void:
	super(length, height)
	$ElevatorCar.room_length = length
	$ElevatorCar.room_height = DEFAULT_HEIGHT
	
	floors = int(height/DEFAULT_HEIGHT)
	$Walls/Left/Doorway.hide()
	var right_doorway = $Walls/Right/Doorway2
	right_doorway.global_position.y = right_doorway.size.y/2
	doorways[0] = right_doorway
	for floor_number in range(1, floors):
		var new_doorway = right_doorway.duplicate()
		doorways[floor_number] = new_doorway
		$Walls/Right.add_child(new_doorway)
		new_doorway.global_position.y = right_doorway.size.y/2 + floor_number * DEFAULT_HEIGHT
	
	

func _input(event: InputEvent) -> void:
	for i in range(1, 6):
		if event.is_action_pressed(str(i)):
			move_car_to_floor(i)

func move_car_to_floor(floor_number:int) -> void:
	var dist = abs($ElevatorCar.global_position.y - (floor_number-1) * DEFAULT_HEIGHT)
	if car_tween:
		car_tween.kill()
	car_tween = get_tree().create_tween()
	car_tween.tween_property($ElevatorCar, "global_position:y", (floor_number-1) * DEFAULT_HEIGHT, dist/CAR_SPEED)
