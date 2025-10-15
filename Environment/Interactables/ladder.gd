extends Node3D





func _on_area_3d_body_entered(body):
	if body is Player:
		body.ladder_array.append(self)
		body.current_control_state = Player.CONTROL_STATE.LADDER


func _on_area_3d_body_exited(body):
	if body is Player:
		body .ladder_array.erase(self)
		if body.ladder_array.size() == 0:
			body.current_control_state = Player.CONTROL_STATE.NORMAL
