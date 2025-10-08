extends Object
class_name InventoryManager

var inventory : Array[Dictionary] = []
var inventory_limit := 4


func get_inventory() -> Array[Dictionary]:
	return inventory



func add_to_inventory(item : Dictionary) -> bool:
	if inventory.size() >= inventory_limit:
		return false
	inventory.append(item)
	return true
