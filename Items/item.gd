extends Area3D
class_name Item

var item_info : Dictionary = {"name" : "pistol", "type": " gun", "ammo" : 20}

func interact(player: Player) -> void:
	player.inventory.append(item_info)
	queue_free()
