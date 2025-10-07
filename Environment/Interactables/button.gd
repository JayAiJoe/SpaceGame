extends StaticBody3D


func interact(player: Player) -> void:
	var tween = get_tree().create_tween().set_trans(Tween.TRANS_CIRC)
	tween.tween_property($ButtonMesh, "position:y", 0.7, 0.2)
	tween.tween_property($ButtonMesh, "position:y", 1.0, 0.2)
