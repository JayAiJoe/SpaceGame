extends Camera3D

func _ready():
	current = true

func teleport_to(target: Transform3D) -> void:
	print("teleported to: " + str(target.origin))
	global_transform = target

func transition_to(target: Transform3D, duration: float = 1.0, tween_ease : Tween.EaseType = Tween.EASE_OUT, trans : Tween.TransitionType = Tween.TRANS_LINEAR) -> void:
	var tween = create_tween().set_ease(tween_ease).set_trans(trans)

	# Store start and end transforms
	var start_pos = global_position
	var start_rot = global_transform.basis.get_rotation_quaternion()
	var end_pos = target.origin
	var end_rot = target.basis.get_rotation_quaternion()

	# Use a custom tween step to interpolate both position + rotation properly
	tween.tween_method(
		func(weight: float):
			global_position = start_pos.lerp(end_pos, weight)
			global_rotation = start_rot.slerp(end_rot, weight).get_euler()
	, 0.0, 1.0, duration)
